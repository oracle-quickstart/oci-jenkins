# OCI Terraform Module Testing Validation Helpers

This library depends on Terratest. While Terratest provides APIs to execute commands through SSH connections and send HTTP get requests, there are a few extra steps that can be wrapped into helper functions that cam make test code cleaner and easier to write/maintain.

## Validation Through SSH
After a solution is deployed through OCI terraform provider, the most common validation is to execute commands through SSH connections on the compute instances in this solution. There are typically two types of instances:

* host with public IP address exposed
* host with private IP address

It is straight-forward to SSH to the host with public IP address. However, in order to SSH to a host with private IP address, a public IP (e.g. a Bastion host) is needed. This library provides helper functions for both scenarios:

* SSHToHost
* SSHToPrivateHost

SSH connection requires a public and private key pair. Terratest has an API to generate a key pair. However, OCI solutions usually require existing public and private keys to apply configurations. The validation will need to use the same key pair. This library provides helper functions to build a key pair from existing public and private key files or the reverse:

* GetKeyPairFromFiles
* GenerateSSHKeyFilesFromKeyPair

## Validation Through HTTP Get Request
If the solution has a WebPage, it is also possible to send an HTTP Get request and validate that the WebPage is accessible via the status code or body in the response or both. Terratest has an API to send simple HTTP get request and returns both status code and body from the response. It also has and API to verify both status code and body. This library provides helper functions to validate either status code or body:

* HTTPGetWithStatusValidation -- sends an HTTP Get request and then validate that the status code is the same as the expected value
* HTTPGetWithBodyValidation -- sends an HTTP Get request and then validate that the response body is the same as the expected value
