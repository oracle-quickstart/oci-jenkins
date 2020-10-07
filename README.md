# oci-jenkins

Deploy Jenkins in master agent mode to take advantage of the clustered configuration of CI/CD pipeline configured in Oracle Cloud Infrastructure.

This reference architecture shows how to deploy Jenkins in master/agent mode by using the Jenkins Oracle Cloud Infrastructure Compute plugin. When installed on a Jenkins master instance, the plugin lets you create agent instances on demand within Oracle Cloud Infrastructure and remove instances or free resources automatically after the build job finishes.

This architecture contains one master instance and two agent instances as a starting point of a deployment. You can adjust the number of agent instances or the size of the master instance as needed. The Jenkins master instance should be installed with the Oracle Cloud Infrastructure plugin code.

## Terraform Provider for Oracle Cloud Infrastructure
The OCI Terraform Provider is now available for automatic download through the Terraform Provider Registry. 
For more information on how to get started view the [documentation](https://www.terraform.io/docs/providers/oci/index.html) 
and [setup guide](https://www.terraform.io/docs/providers/oci/guides/version-3-upgrade.html).

* [Documentation](https://www.terraform.io/docs/providers/oci/index.html)
* [OCI forums](https://cloudcustomerconnect.oracle.com/resources/9c8fa8f96f/summary)
* [Github issues](https://github.com/terraform-providers/terraform-provider-oci/issues)
* [Troubleshooting](https://www.terraform.io/docs/providers/oci/guides/guides/troubleshooting.html)

## Clone the Module
Now, you'll want a local copy of this repo. You can make that with the commands:

    git clone https://github.com/oracle-quickstart/oci-jenkins.git
    cd oci-jenkins
    git checkout orm
    ls

## Prerequisites
First off, you'll need to do some pre-deploy setup.  That's all detailed [here](https://github.com/cloud-partners/oci-prerequisites).

Secondly, create a `terraform.tfvars` file and populate with the following information:

```
# Authentication
tenancy_ocid         = "<tenancy_ocid>"
user_ocid            = "<user_ocid>"
fingerprint          = "<finger_print>"
private_key_path     = "<pem_private_key_path>"

# SSH Keys
ssh_public_key  = "<public_ssh_key_path>"
ssh_private_key  = "<private_ssh_key_path>"

# Region
region = "<oci_region>"

# Compartment
compartment_ocid = "<compartment_ocid>"

# Jenkins password
jenkins_password = "<jenkins_password>"

````

Deploy:

    terraform init
    terraform plan
    terraform apply

## Destroy the Deployment
When you no longer need the deployment, you can run this command to destroy it:

    terraform destroy

## Jenkins in master agent mode Architecture

![](./images/oci-jenkins.png)

## Reference Archirecture

- [Deploy Jenkins in master/agent mode](https://docs.oracle.com/en/solutions/jenkins-master-agent-mode/index.html)
