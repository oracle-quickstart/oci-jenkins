package test

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"testing"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/test-structure"
)

// An example of how to test the simple Terraform module in examples/terraform-basic-example using Terratest.
func TestTerraformJenkins(t *testing.T) {
	t.Parallel()

	// The folder where we have our Terraform code
	workingDir := "../examples/example-1"

	// At the end of the test, clean up all the resources we created
	defer test_structure.RunTestStage(t, "teardown", func() {
		//undeployUsingTerraform(t, workingDir)
	})

	// Deploy the  app
	test_structure.RunTestStage(t, "deploy_initial", func() {
		initialDeploy(t, workingDir)
	})

	// Validate that the Jenkins Server deployed and is responding to HTTP requests
	test_structure.RunTestStage(t, "validate_master", func() {
		validateJenkinsMasterServer(t, workingDir)
	})

	// Validate Jenkins Plugin installation through Jenkins REST API
	//test_structure.RunTestStage(t, "validate_plugin", func() {
	//validateJenkinsPlugin(t, workingDir)
	//})

	// Validate that the Jenkins Server deployed and is responding to HTTP requests
	//test_structure.RunTestStage(t, "validate_slave", func() {
	//validateJenkinsSlaveServer(t, workingDir)
	//})

}

// Do the initial deployment
func initialDeploy(t *testing.T, workingDir string) {
	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: workingDir,
	}

	// Save the Terraform Options struct so future test stages can use it
	test_structure.SaveTerraformOptions(t, workingDir, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.Init(t, terraformOptions)
	out, err := terraform.RunTerraformCommandE(t, terraformOptions, terraform.FormatArgs(terraformOptions.Vars, "apply", "-input=false", "-lock=false", "-auto-approve", "-parallelism=1")...)
	if err != nil {
		t.Fatal(err)
		logger.Logf(t, "Output: ", out)
	}
}

// Validate the Jenkins Master Server has been deployed and is working
func validateJenkinsMasterServer(t *testing.T, workingDir string) {
	// Load the Terraform Options saved by the earlier deploy_terraform stage
	terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)
	url := terraform.Output(t, terraformOptions, "master_login_url")
	password := terraform.Output(t, terraformOptions, "master_login_init_password")

	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		t.Fatal(err)
	}
	//Send BasicAuth
	req.SetBasicAuth("admin", password)

	//Get response
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatal(err)
	}

	// Verify that we get back a 200 OK with the response code
	if resp.StatusCode != http.StatusOK {
		t.Errorf("expect status OK, but got %v", resp.Status)
	} else {
		fmt.Printf("Jenkins Master is working, response status is %v\n", resp.Status)
	}

	defer resp.Body.Close()

}

// Validate the Jenkins Plugins defined in Variable has been installed
func validateJenkinsPlugin(t *testing.T, workingDir string) {
	// Load the Terraform Options saved by the earlier deploy_terraform stage
	terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)
	url := terraform.Output(t, terraformOptions, "master_login_url")
	password := terraform.Output(t, terraformOptions, "master_login_init_password")

	req, err := http.NewRequest("GET", url+"/pluginManager/api/json?depth=1&tree=plugins[shortName]", nil)
	if err != nil {
		t.Fatal(err)
	}
	req.SetBasicAuth("admin", password)

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatal(err)
	}

	if resp.StatusCode != http.StatusOK {
		t.Errorf("expect status OK, but got %v", resp.Status)
	}

  defer resp.Body.Close()
	body, readErr := ioutil.ReadAll(resp.Body)
	if readErr != nil {
		t.Fatal(readErr)
	}

	var pluginJson PluginJson
	err = json.Unmarshal([]byte(body), &pluginJson)

	if err != nil {
		t.Fatal(err)
	}

	if containsPlugin("oracle-cloud-infrastructure-compute", pluginJson.Plugins) {
		fmt.Printf("user plugin %v installed\n", "oracle-cloud-infrastructure-compute")
	} else {
		t.Errorf("failed install plugin %v\n", "oracle-cloud-infrastructure-compute")
	}

	defer resp.Body.Close()

}

// Validate the Jenkins Master Server has been deployed and is working
func validateJenkinsSlaveServer(t *testing.T, workingDir string) {
	//TODO: http://<jenkins_master_url>/computer/api/json?pretty=true
}

func undeployUsingTerraform(t *testing.T, workingDir string) {

	terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)
	terraform.Destroy(t, terraformOptions)
}

func containsPlugin(str string, plugins Plugins) bool {
	for _, v := range plugins {
		if v.ShortName == str {
			return true
		}
	}
	return false
}

type PluginJson struct {
	Class   string
	Plugins Plugins
}

type Plugins []struct {
	ShortName string
}
