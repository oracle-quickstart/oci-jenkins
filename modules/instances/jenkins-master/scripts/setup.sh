#!/bin/bash
set -e -x

function waitForJenkins() {
    echo "Waiting for Jenkins to launch on ${http_port}..."

    while ! timeout 1 bash -c "echo > /dev/tcp/localhost/${http_port}"; do
      sleep 1
    done

    echo "Jenkins launched"
}

function waitForPasswordFile() {
    echo "Waiting for Jenkins to generate password..."

    while [ ! -f /var/lib/jenkins/secrets/initialAdminPassword ]; do
      sleep 2 # wait for 1/10 of the second before check again
    done

    sudo cat /var/lib/jenkins/secrets/initialAdminPassword > /home/opc/secret
    echo "Password created"
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
sudo cp /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar /var/lib/jenkins/jenkins-cli.jar

waitForPasswordFile

PASS=$(sudo bash -c "cat /var/lib/jenkins/secrets/initialAdminPassword")

sleep 10

# SET AGENT PORT
xmlstarlet ed -u "//slaveAgentPort" -v "${jnlp_port}" /var/lib/jenkins/config.xml > /home/opc/jenkins_config.xml
sudo mv /home/opc/jenkins_config.xml /var/lib/jenkins/config.xml
sudo service jenkins restart

waitForJenkins

sleep 10

# INSTALL PLUGINS
sudo java -jar /var/lib/jenkins/jenkins-cli.jar -s http://localhost:${http_port} -auth admin:$PASS install-plugin ${plugins}

# RESTART JENKINS TO ACTIVATE PLUGINS
sudo java -jar /var/lib/jenkins/jenkins-cli.jar -s http://localhost:${http_port} -auth admin:$PASS restart
