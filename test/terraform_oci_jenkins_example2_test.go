package test

import (
	"strings"

	"testing"

	"github.com/stretchr/testify/assert"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/ssh"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/test-structure"

	"terraform-module-test-lib"
)

func TestModuleJenkinsExample2(t *testing.T) {
	terraformDir := "../examples/example-2"

	terraformOptions := configureTerraformOptions(t, terraformDir)

	defer test_structure.RunTestStage(t, "destroy", func() {
		logger.Log(t, "terraform destroy ...")
		terraform.Destroy(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "init", func() {
		logger.Log(t, "terraform init ...")
		terraform.Init(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "apply", func() {
		logger.Log(t, "terraform apply ...")
		terraform.Apply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		logger.Log(t, "Verfiying  ...")
		validateSolution(t, terraformOptions)
	})
}

func configureTerraformOptions(t *testing.T, terraformDir string) *terraform.Options {
	var vars Inputs
	err := test_helper.GetConfig("inputs_config.json", &vars)
	if err != nil {
		logger.Logf(t, err.Error())
		t.Fail()
	}
	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/example-2",
		Vars: map[string]interface{}{
			"tenancy_ocid":        vars.Tenancy_ocid,
			"user_ocid":           vars.User_ocid,
			"fingerprint":         vars.Fingerprint,
			"region":              vars.Region,
			"compartment_ocid":    vars.Compartment_ocid,
			"private_key_path":    vars.Private_key_path,
			"ssh_authorized_keys": vars.Ssh_authorized_keys,
			"ssh_private_key":     vars.Ssh_private_key,
		},
	}
	return terraformOptions
}

func validateSolution(t *testing.T, terraformOptions *terraform.Options) {
	// build key pair for ssh connections
	ssh_public_key_path := terraformOptions.Vars["ssh_authorized_keys"].(string)
	ssh_private_key_path := terraformOptions.Vars["ssh_private_key"].(string)
	key_pair, err := test_helper.GetKeyPairFromFiles(ssh_public_key_path, ssh_private_key_path)
	if err != nil {
		assert.NotNil(t, key_pair)
	}
	validateBySSHToPublicHost(t, terraformOptions, key_pair)
	validateBySSHToPrivateHost(t, terraformOptions, key_pair)
	// validateByHTTPGet(t, terraformOptions)
}

func getURL(t *testing.T, terraformOptions *terraform.Options) string {
	login_info := terraform.Output(t, terraformOptions, "master_login_info")
	lines := strings.Split(login_info, ",")
	for i := 0; i < len(lines); i++ {
		if strings.Contains(lines[i], "Jenkins Master URL") {
			url := strings.TrimSpace(strings.SplitN(lines[i], ":", 2)[1])
			return url
		}
	}
	return ""
}

func getPassword(t *testing.T, terraformOptions *terraform.Options) string {
	login_info := terraform.Output(t, terraformOptions, "master_login_info")
	lines := strings.Split(login_info, ",")
	for i := 0; i < len(lines); i++ {
		if strings.Contains(lines[i], "Admin Initial Password") {
			url := strings.TrimSpace(strings.SplitN(lines[i], ":", 2)[1])
			return url
		}
	}
	return ""
}

func validateByHTTPGet(t *testing.T, terraformOptions *terraform.Options) {
	url := getURL(t, terraformOptions)
	password := getPassword(t, terraformOptions)
	assert.NotEqual(t, url, "")
	assert.NotEqual(t, password, "")
	status_code, body := test_helper.HTTPGetWithAuth(t, url, "admin", password)
	logger.Logf(t, "Status code: %v; body: %s", status_code, body)
	assert.Equal(t, status_code, 200)
}

func validateBySSHToPublicHost(t *testing.T, terraformOptions *terraform.Options, key_pair *ssh.KeyPair) {
	command := "ls /var/lib/jenkins/"
	master_public_ip := terraform.Output(t, terraformOptions, "master_public_ip")
	result := test_helper.SSHToHost(t, master_public_ip, "opc", key_pair, command)
	assert.True(t, strings.Contains(result, "config.xml"))
}

func validateBySSHToPrivateHost(t *testing.T, terraformOptions *terraform.Options, key_pair *ssh.KeyPair) {
	command := "ls /tmp/setup_slave.sh"
	master_public_ip := terraform.Output(t, terraformOptions, "master_public_ip")
	slave_private_ips := terraform.Output(t, terraformOptions, "slave_private_ips")
	private_ips := strings.Split(slave_private_ips, ",")
	for i := 0; i < len(private_ips); i++ {
		ip := strings.TrimSpace(private_ips[i])
		result := test_helper.SSHToPrivateHost(t, master_public_ip, ip, "opc", key_pair, command)
		assert.True(t, strings.Contains(result, "setup_slave.sh"))
	}
}
