#!/bin/bash
set -e -x

function waitForJenkins() {
    echo "Waiting for Jenkins to launch on ${http_port}..."

    while ! timeout 1 bash -c "echo > /dev/tcp/localhost/${http_port}"; do
      sleep 1
    done

    echo "Jenkins launched"
}

# Install Java for Jenkins
sudo yum install -y java-1.8.0-openjdk

# Install xmlstarlet used for XML config manipulation
sudo yum install -y xmlstarlet

# Install Jenkins
sudo echo "[jenkins-ci-org-${jenkins_version}]"
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum install -y jenkins-${jenkins_version}

# Config Jenkins Http Port
sudo sed -i '/JENKINS_PORT/c\ \JENKINS_PORT=\"${http_port}\"' /etc/sysconfig/jenkins
sudo sed -i '/JENKINS_JAVA_OPTIONS/c\ \JENKINS_JAVA_OPTIONS=\"-Djenkins.install.runSetupWizard=false -Djava.awt.headless=true\"' /etc/sysconfig/jenkins
# Start Jenkins
sudo service jenkins restart
sudo chkconfig --add jenkins

# Set httpport on firewall
sudo firewall-cmd --zone=public --permanent --add-port=${http_port}/tcp
sudo firewall-cmd --zone=public --permanent --add-port=${jnlp_port}/tcp
sudo firewall-cmd --zone=public --permanent --add-port=443/tcp
sudo firewall-cmd --reload

waitForJenkins

# UPDATE PLUGIN LIST
curl  -L http://updates.jenkins-ci.org/update-center.json | sed '1d;$d' | curl -X POST -H 'Accept: application/json' -d @- http://localhost:${http_port}/updateCenter/byId/default/postBack

sleep 10

waitForJenkins

# INSTALL CLI
sudo wget -P /var/lib/jenkins/ http://localhost:8080/jnlpJars/jenkins-cli.jar

sleep 10

# Set Agent Port
xmlstarlet ed -u "//slaveAgentPort" -v "${jnlp_port}" /var/lib/jenkins/config.xml > /home/opc/jenkins_config.xml
sudo mv /home/opc/jenkins_config.xml /var/lib/jenkins/config.xml

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
