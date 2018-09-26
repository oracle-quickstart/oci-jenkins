#!/bin/bash
set -e -x

# Install Java for Jenkins
wget --no-check-certificate -c --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/10.0.2+13/19aef61b38124481863b1413dce1855f/jdk-10.0.2_linux-x64_bin.rpm
sudo rpm -ivh jdk-10.0.2_linux-x64_bin.rpm

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
