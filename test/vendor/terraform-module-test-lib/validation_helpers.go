// Package validation_helpers contains helper functions to validate terraform oci solutions
package test_helper

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"

	"github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/ssh"
)

// CreateTempFile creates a temp file with the content passed in. The file path is returned.
// It is the responsibility of the caller of this function to call os.Remove() to delete this file once
// it is no longer used.
func CreateTempFile(t *testing.T, file_prefix string, content []byte) string {
	tmp_file, err := ioutil.TempFile("", "pub_key")
	if err != nil {
		t.Fail()
	}
	if _, err := tmp_file.Write(content); err != nil {
		t.Fail()
	}
	if err := tmp_file.Close(); err != nil {
		t.Fail()
	}
	return tmp_file.Name()
}

// GenerateSSHKeyFilesFromKeyPair reads the PublicKey and PrivateKey from the ssh key_pair passed in, and
// creates two temp files, one containing the public key and the other one containing the private key.
// It is the responsibility of the caller of this function to call os.Remove() to delete these files once
// they are no longer used.
func GenerateSSHKeyFilesFromKeyPair(t *testing.T, key_pair *ssh.KeyPair) (string, string) {
	public_key_content := []byte(key_pair.PublicKey)
	public_key_file := CreateTempFile(t, "public_key", public_key_content)
	private_key_content := []byte(key_pair.PrivateKey)
	private_key_file := CreateTempFile(t, "private_key", private_key_content)

	return public_key_file, private_key_file
}

// GetKeyPairFromFiles reads public and private keys from the given paths and build key pair struct defined in terratest
func GetKeyPairFromFiles(ssh_public_key_path string, ssh_private_key_path string) (*ssh.KeyPair, error) {
	var err error
	ssh_public_key, e := ioutil.ReadFile(ssh_public_key_path)
	if e != nil {
		err = fmt.Errorf("Error reading ssh public key file \"%s\": %s", ssh_public_key_path, e.Error())
	} else {
		ssh_private_key, e := ioutil.ReadFile(ssh_private_key_path)
		if e != nil {
			err = fmt.Errorf("Error reading ssh private key file \"%s\": %s", ssh_private_key_path, e.Error())
		} else {
			return &ssh.KeyPair{PublicKey: string(ssh_public_key), PrivateKey: string(ssh_private_key)}, nil
		}
	}
	return nil, err
}

// SSHToHost SSH to host using its public ip and execute the command given in the parameter
func SSHToHost(t *testing.T, host_name string, ssh_user_name string, key_pair *ssh.KeyPair, command string) string {
	host := ssh.Host{
		Hostname:    host_name,
		SshKeyPair:  key_pair,
		SshUserName: ssh_user_name,
	}
	ssh.CheckSshConnection(t, host)
	logger.Logf(t, "Will ssh to %s and run command %s", host_name, command)
	ssh_result := ssh.CheckSshCommand(t, host, command)

	return ssh_result
}

// SSHToPrivateHost SSH to host using its private ip and execute the command given in the parameter
// A public ip is used to hop to the private ip. This is usually used in the master/slave configuration
// where the master is accessible through public ip while the slaves are accessible through master
func SSHToPrivateHost(t *testing.T, public_host_name string, private_host_name string, ssh_user_name string,
	key_pair *ssh.KeyPair, command string) string {
	public_host := ssh.Host{
		Hostname:    public_host_name,
		SshKeyPair:  key_pair,
		SshUserName: ssh_user_name,
	}

	private_host := ssh.Host{
		Hostname:    private_host_name,
		SshKeyPair:  key_pair,
		SshUserName: ssh_user_name,
	}
	ssh.CheckPrivateSshConnection(t, public_host, private_host, "exit")
	logger.Logf(t, "Will ssh to %s through %s and run command %s", private_host_name, public_host_name, command)
	ssh_result := ssh.CheckPrivateSshConnection(t, public_host, private_host, command)

	return ssh_result
}

func HTTPGetWithAuth(t *testing.T, url string, username string, password string) (int, string) {
	req, err := http.NewRequest("GET", url, nil)
	assert.Nil(t, err)
	req.SetBasicAuth(username, password)
	response, err := http.DefaultClient.Do(req)
	if err != nil {
		logger.Logf(t, err.Error())
	}
	assert.Nil(t, err)
	assert.Equal(t, response.StatusCode, http.StatusOK)
	logger.Logf(t, "Status body: %s", response.Body)
	body, err := ioutil.ReadAll(response.Body)
	assert.Nil(t, err)
	return response.StatusCode, string(body)
}

// HTTPGetWithStatusValidation sends HTTP get request to the URL given in the parameter and verify that the response status is expected
func HTTPGetWithStatusValidation(t *testing.T, url string, expected_status int) {
	status, _ := http_helper.HttpGet(t, url)
	assert.Equal(t, status, expected_status)
}

// HTTPGetWithBodyValidation sends HTTP get request to the URL given in the parameter and verify that the response body is expected
func HTTPGetWithBodyValidation(t *testing.T, url string, expected_body string) {
	_, body := http_helper.HttpGet(t, url)
	assert.Equal(t, strings.Compare(body, expected_body), 0)
}

func GetConfig(config_path string, configuration interface{}) error {
	raw, err := ioutil.ReadFile(config_path)
	if err != nil {
		return fmt.Errorf("Unable to read from configuration file: %s", err.Error())
	}
	err = json.Unmarshal(raw, &configuration)
	if err != nil {
		return fmt.Errorf("Failed to parse configurations: %s", err.Error())
	}
	return nil
}
