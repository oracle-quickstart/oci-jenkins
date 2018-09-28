#!/bin/bash
set -e -x

# Install Java for Jenkins
wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u181-b13/96a7b8442fe848ef90c96a2fad6ed6d1/jdk-8u181-linux-x64.rpm"
sudo rpm -ivh jdk-8u181-linux-x64.rpm

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
