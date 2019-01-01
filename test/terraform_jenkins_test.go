package test

import (
	"fmt"
	"testing"
        "github.com/gruntwork-io/terratest/modules/test-structure"
        "terraform-module-test-lib"
	"github.com/bndr/gojenkins"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/ssh"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraJenkins(t *testing.T) {
	terraform_dir := "../examples/quick_start"
	terraform_options := configureTerraformOptions(t, terraform_dir)
	test_structure.RunTestStage(t, "init", func() {
		logger.Log(t, "terraform init ...")
		terraform.Init(t, terraform_options)
	})
	defer test_structure.RunTestStage(t, "destroy", func() {
		logger.Log(t, "terraform destroy  ...")
		terraform.Destroy(t, terraform_options)
	})
	test_structure.RunTestStage(t, "apply", func() {
		logger.Log(t, "terraform apply ...")
		terraform.Apply(t, terraform_options)
	})
	test_structure.RunTestStage(t, "validate", func() {
		logger.Log(t, "Verfiying  ...")
		validateSolution(t, terraform_options)
	})
}
func configureTerraformOptions(t *testing.T, terraform_dir string) *terraform.Options {
	var vars Inputs
	err := test_helper.GetConfig("inputs_config.json", &vars)
	if err != nil {
		logger.Log(t, err.Error())
		t.Fail()
	}
	terraformOptions := &terraform.Options{
		TerraformDir: terraform_dir,
		Vars: map[string]interface{}{
			"tenancy_ocid":            vars.Tenancy_ocid,
			"user_ocid":               vars.User_ocid,
			"fingerprint":             vars.Fingerprint,
			"region":                  vars.Region,
			"compartment_ocid":        vars.Compartment_ocid,
			"private_key_path":        vars.Private_key_path,
			"ssh_authorized_keys":     vars.Ssh_authorized_keys,
			"ssh_private_key":         vars.Ssh_private_key,
			"jenkins_password":        vars.Jenkins_password,
			"bastion_authorized_keys": vars.Bastion_authorized_keys,
			"bastion_private_key":     vars.Bastion_private_key,
		},
	}
	return terraformOptions
}
func validateSolution(t *testing.T, terraform_options *terraform.Options) {
	ssh_private_key_path := terraform_options.Vars["ssh_private_key"].(string)
	ssh_public_key_path := terraform_options.Vars["ssh_authorized_keys"].(string)
	key := terraform_options.Vars["jenkins_password"].(string)
	key_pair, err := test_helper.GetKeyPairFromFiles(ssh_public_key_path, ssh_private_key_path)
	if err != nil {
		assert.NotNil(t, key_pair)
	}
	testJenkins(t, terraform_options, key_pair, key)
}
func testJenkins(t *testing.T, terraform_options *terraform.Options, key_pair *ssh.KeyPair, key string) {
	slave_private_name0 := "JenkinsSlave-1"
	slave_private_name1 := "JenkinsSlave-2"
	master_login_url_tf := terraform.Output(t, terraform_options, "jenkins_login_url")
	master_login_url := master_login_url_tf + "/"
	jenkins := gojenkins.CreateJenkins(nil, master_login_url, "admin", key)
	j, err := jenkins.Init()
	if err != nil {
		panic("Something Went Wrong")
		fmt.Println(err)
		fmt.Println("err")
	}
	configString := `<?xml version='1.0' encoding='UTF-8'?>
  <project>
  <actions/>
  <description></description>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <scm class="hudson.scm.NullSCM"/>
  <canRoam>true</canRoam>
  <disabled>false</disabled>
  <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
  <blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>
  <triggers class="vector"/>
  <concurrentBuild>false</concurrentBuild>
  <builders/>
  <publishers/>
  <buildWrappers/>
</project>`
	_, err = j.GetNode(slave_private_name0)
	if err != nil {
		panic("Could not get jenkins slave node1")
		fmt.Println(err)
	}
	_, err = j.GetNode(slave_private_name1)
	if err != nil {
		panic("Could not get jenkins slave node2")
		fmt.Println(err)
	}
	_, err = j.CreateJob(configString, "NewJob")
	if err != nil {
		panic("Could not create job ")
		fmt.Println(err)
	}
	_, err = j.BuildJob("NewJob")
	if err != nil {
		panic("Could not build job ")
		fmt.Println(err)
	}
	p, _ := j.HasPlugin("Oracle Cloud Infrastructure Compute Plugin")

	if p == nil {
		panic("Could not find the oci plugin ")
		fmt.Println("err")
	}
	_, err = j.DeleteJob("NewJob")
	if err != nil {
		panic("Could not delete job ")
		fmt.Println(err)
	}
}
