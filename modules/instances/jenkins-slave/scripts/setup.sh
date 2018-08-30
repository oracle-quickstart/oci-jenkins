#!/bin/bash
set -e -x

# Install Java for Jenkins
sudo yum install -y java

# Config jenkins user on slave node
sudo useradd --home-dir /home/jenkins --create-home --shell /bin/bash jenkins
mkdir /home/jenkins/jenkins-slave
sudo chown -R jenkins:jenkins /home/jenkins

# Get password and dependencies from master node
chmod 0600 /tmp/key.pem
ssh -oStrictHostKeyChecking=no -i /tmp/key.pem opc@${jenkins_master_ip} 'sudo cat /var/lib/jenkins/secrets/initialAdminPassword' > /tmp/secret

# Get dependencies from master node
wget -P /tmp ${jenkins_master_url}/jnlpJars/jenkins-cli.jar
wget -P /tmp ${jenkins_master_url}/jnlpJars/slave.jar
sudo mv /tmp/slave.jar /home/jenkins/jenkins-slave/
