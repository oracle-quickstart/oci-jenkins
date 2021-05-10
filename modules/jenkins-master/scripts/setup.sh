#!/bin/bash
set -e -x

function waitForJenkins() {
    echo "Waiting for Jenkins to launch on ${http_port}..."
    i=0
    while ! timeout 1 bash -c "echo > /dev/tcp/localhost/${http_port}"; do
      sleep 1
      ((i=$i+1))
      ### every 30s, restart jenkins service
      if [ $(( $i % 30 )) -eq 0 ]; then
        echo "Connection refused, restarting jenkins"
        sudo service jenkins restart
      fi

      ### after 5m, fail
      if [ $(( $i % 300 )) -eq 0 ]; then
        echo "Failed to connect to jenkins during installation process, exiting"
        exit -1
      fi
    done

    echo "Jenkins launched"
}

#Enable Developer repo (EPEL)
sudo yum-config-manager --enable ol7_developer*

# Install Java for Jenkins
sudo yum install -y java-1.8.0-openjdk

# Install Jenkins
sudo echo "[jenkins-ci-org-${jenkins_version}]"
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key

sudo yum install -y jenkins-${jenkins_version}

# Config Jenkins Http Port and Agent Port using System/Java properties - https://www.jenkins.io/doc/book/managing/system-properties/
sudo sed -i '/JENKINS_PORT/c\ \JENKINS_PORT=\"${http_port}\"' /etc/sysconfig/jenkins
sudo sed -i '/JENKINS_JAVA_OPTIONS/c\ \JENKINS_JAVA_OPTIONS=\"-Djenkins.install.runSetupWizard=false -Djava.awt.headless=true -Djenkins.model.Jenkins.slaveAgentPort=${jnlp_port}\"' /etc/sysconfig/jenkins

# Set httpport on firewall
sudo firewall-cmd --zone=public --permanent --add-port=${http_port}/tcp
sudo firewall-cmd --zone=public --permanent --add-port=${jnlp_port}/tcp
sudo firewall-cmd --zone=public --permanent --add-port=443/tcp
sudo firewall-cmd --reload

# Start Jenkins
sudo service jenkins restart
sudo chkconfig --add jenkins

waitForJenkins

sleep 10 

# UPDATE PLUGIN LIST
curl  -L http://updates.jenkins-ci.org/update-center.json | sed '1d;$d' | curl -X POST -H 'Accept: application/json' -d @- http://localhost:${http_port}/updateCenter/byId/default/postBack

sleep 10

waitForJenkins

# INSTALL CLI
sudo wget -P /var/lib/jenkins/ http://localhost:8080/jnlpJars/jenkins-cli.jar

sleep 10

# Initialize Jenkins User Password Groovy Script
export PASS=${jenkins_password}

sudo -u jenkins mkdir -p /var/lib/jenkins/init.groovy.d
sudo mv /home/opc/default-user.groovy /var/lib/jenkins/init.groovy.d/default-user.groovy

sudo service jenkins restart

sleep 10 

waitForJenkins

sleep 60

# INSTALL PLUGINS
sudo java -jar /var/lib/jenkins/jenkins-cli.jar -s http://localhost:${http_port} -auth admin:$PASS install-plugin ${plugins}

# RESTART JENKINS TO ACTIVATE PLUGINS
sudo java -jar /var/lib/jenkins/jenkins-cli.jar -s http://localhost:${http_port} -auth admin:$PASS restart
