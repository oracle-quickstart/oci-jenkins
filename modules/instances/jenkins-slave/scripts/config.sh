#!/bin/bash

export PASS=$(sudo bash -c "cat /tmp/secret")

# Register node as Slave
cat <<EOF | java -jar /tmp/jenkins-cli.jar -s ${jenkins_master_url} -auth admin:$PASS create-node $1
<slave>
  <name>$1</name>
  <remoteFS>/home/jenkins</remoteFS>
  <numExecutors>2</numExecutors>
  <launcher class="hudson.slaves.JNLPLauncher" />
  <label>build</label>
</slave>
EOF


export TOKEN=$(curl --user "admin:$PASS" -s ${jenkins_master_url}/crumbIssuer/api/json | python -c 'import sys,json;j=json.load(sys.stdin);print j["crumbRequestField"] + "=" + j["crumb"]')

cat > /tmp/secret.groovy <<EOF
for (aSlave in hudson.model.Hudson.instance.slaves) {
  if (aSlave.name == "$1") {
    println aSlave.name + "," + aSlave.getComputer().getJnlpMac()
  }
}
EOF

export SECRET=$(curl --user "admin:$PASS" -d "$TOKEN" --data-urlencode "script=$(</tmp/secret.groovy)" ${jenkins_master_url}/scriptText | awk -F',' '{print $2}')

# Run from service definition
sudo chown -R jenkins:jenkins /home/jenkins/jenkins-slave
cmd="java -jar /home/jenkins/jenkins-slave/slave.jar -jnlpUrl ${jenkins_master_url}/computer/$1/slave-agent.jnlp -secret $SECRET"
echo $cmd
nohup sudo -u jenkins $cmd &>/tmp/jenkins.log &

sleep 10

# Echo Master admin init password for login
echo "Jenkins Master Login User/Password: admin/$PASS"
