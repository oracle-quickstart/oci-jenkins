#!groovy

import jenkins.model.*
import hudson.security.*
import jenkins.security.s2m.AdminWhitelistRule

// Get Jenkins initial user and password from file
Properties properties = new Properties()
File propertiesFile = new File('/var/lib/jenkins/initialUserPassword')
propertiesFile.withInputStream {
    properties.load(it)
}

// Give default username and password if initialUserPassword file is not provided
def jenkins_user = (properties.JENKINS_USER!=null && properties.JENKINS_USER.length()>0) ? properties.JENKINS_USER : 'admin'
def jenkins_pass = (properties.JENKINS_PASS!=null && properties.JENKINS_PASS.length()>0) ? properties.JENKINS_PASS : 'admin'
def instance = Jenkins.getInstance()

def hudsonRealm = new HudsonPrivateSecurityRealm(false)

hudsonRealm.createAccount(jenkins_user, jenkins_pass)
instance.setSecurityRealm(hudsonRealm)

def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
instance.setAuthorizationStrategy(strategy)
instance.save()

Jenkins.instance.getInjector().getInstance(AdminWhitelistRule.class).setMasterKillSwitch(false)
