#!/bin/bash
set -e -x

# Install Java for Jenkins
sudo yum install -y java-1.8.0-openjdk

# Config jenkins user on agent node
sudo useradd --home-dir /home/jenkins --create-home --shell /bin/bash jenkins
sudo mkdir /home/jenkins/jenkins-agent
sudo chown -R jenkins:jenkins /home/jenkins

# Get dependencies from controller node
wget -P /home/opc/tmp ${jenkins_controller_url}/jnlpJars/jenkins-cli.jar
wget -P /home/opc/tmp ${jenkins_controller_url}/jnlpJars/slave.jar
sudo mv /home/opc/tmp/slave.jar /home/jenkins/jenkins-agent/

# Get Jenkins User Password
export PASS=${jenkins_password}

# Register node as Slave
cat <<EOF | java -jar /home/opc/tmp/jenkins-cli.jar -s ${jenkins_controller_url} -auth admin:$PASS create-node $1
<slave>
  <name>$1</name>
  <remoteFS>/home/jenkins</remoteFS>
  <numExecutors>2</numExecutors>
  <launcher class="hudson.slaves.JNLPLauncher" />
  <label>build</label>
</slave>
EOF


export _COOKIE_JAR=$(mktemp)
export TOKEN=$(curl -c "$_COOKIE_JAR" --user "admin:$PASS" -s ${jenkins_controller_url}/crumbIssuer/api/json | python -c 'import sys,json;j=json.load(sys.stdin);print j["crumbRequestField"] + "=" + j["crumb"]')

cat > /home/opc/secret.groovy <<EOF
for (aSlave in hudson.model.Hudson.instance.slaves) {
  if (aSlave.name == "$1") {
    println aSlave.name + "," + aSlave.getComputer().getJnlpMac()
  }
}
EOF

export SECRET=$(curl -b "$_COOKIE_JAR" --user "admin:$PASS" -d "$TOKEN" --data-urlencode "script=$(</home/opc/secret.groovy)" ${jenkins_controller_url}/scriptText | awk -F',' '{print $2}')

rm "$_COOKIE_JAR"
unset _COOKIE_JAR

# Run from service definition
sudo chown -R jenkins:jenkins /home/jenkins/jenkins-agent
cmd="java -jar /home/jenkins/jenkins-agent/slave.jar -jnlpUrl ${jenkins_controller_url}/computer/$1/slave-agent.jnlp -secret $SECRET"
echo $cmd
nohup sudo -u jenkins $cmd &>/home/opc/jenkins.log &

sleep 10

# Echo Controller admin init password for login
echo "Jenkins Controller Login User/Password: admin/$PASS"
