#!/bin/bash
set -e -x

# Install Java for Jenkins
sudo yum install -y java-1.8.0-openjdk

# Config jenkins user on slave node
sudo useradd --home-dir /home/jenkins --create-home --shell /bin/bash jenkins
mkdir /home/jenkins/jenkins-slave
sudo chown -R jenkins:jenkins /home/jenkins

# Get password and dependencies from master node
chmod 0600 /home/opc/key.pem
ssh -oStrictHostKeyChecking=no -i /home/opc/key.pem opc@${jenkins_master_ip} 'sudo cat /var/lib/jenkins/secrets/initialAdminPassword' > /home/opc/secret

# Get dependencies from master node
wget -P /home/opc/tmp ${jenkins_master_url}/jnlpJars/jenkins-cli.jar
wget -P /home/opc/tmp ${jenkins_master_url}/jnlpJars/slave.jar
sudo mv /home/opc/tmp/slave.jar /home/jenkins/jenkins-slave/
