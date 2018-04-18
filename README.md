# Jenkins Oracle Cloud Infrastructure Module


## About
The Jenkins Oracle Cloud Infrastructure Module provides a Terraform-based Jenkins cluster installation for Oracle Cloud Infrastructure (OCI). Jenkins is a distributed automation server, generally associated with Continuous Integration (CI) and Continuous Delivery (CD). A Jenkins cluster typically involves one or more master instance(s) coupled with one or more slave instance(s).


## Prerequisites
1. Download and install Terraform (v0.10.3 or later)
2. Download and install the OCI Terraform Provider (v2.0.0 or later)
3. Export OCI credentials. (this refer to the https://github.com/oracle/terraform-provider-oci )


## What's a Module?
A Module is a canonical, reusable, best-practices definition for how to run a single piece of infrastructure, such as a database or server cluster. Each Module is created using Terraform, and includes automated tests, examples, and documentation. It is maintained both by the open source community and companies that provide commercial support.
Instead of figuring out the details of how to run a piece of infrastructure from scratch, you can reuse existing code that has been proven in production. And instead of maintaining all that infrastructure code yourself, you can leverage the work of the Module community to pick up infrastructure improvements through a version number bump.

## How to use this Module
Each Module has the following folder structure:
* [root](): This folder shows an example of Terraform code that uses the jenkins-master and jenkins-slave module(s) to deploy a Jenkins cluster in OCI.
* [modules](): This folder contains the reusable code for this Module, broken down into one or more modules.
< ---------- we don't have examples, in case that we use it later, leave it here ------------>
* [examples](): This folder contains examples of how to use the modules.

To deploy Jenkins servers using this Module:

Create a Jenkins Master OCI instance using this module:
```
terraform init

terraform plan --var "tenancy_ocid=" \
--var "user_ocid=" \
--var "fingerprint=" \
--var "private_key_path=" \
--var "region=" \
--var "compartment_ocid=" \
--var "ssh_public_key=" \
--var "ssh_private_key="


terraform apply --var "tenancy_ocid=" \
--var "user_ocid=" \
--var "fingerprint=" \
--var "private_key_path=" \
--var "region=" \
--var "compartment_ocid=" \
--var "ssh_public_key=" \
--var "ssh_private_key="

```
Argument | Description
--- | ---
tenancy_ocid |
user_ocid |
fingerprint |
private_key_path | Path to SSH private key used for provisioning
region |
compartment_ocid |
ssh_public_key | SSH public key name
ssh_private_key | SSH private key name
network_cidrs |
vcn_dns_name |
label_prefix | To create unique identifier for multiple clusters in a compartment.
master_ol_image_name | The image name to be used on the master instance
slave_ol_image_name | The image name to be used on the slave instance
jenkinsMasterShape | The shape to be used on the master instance
jenkinsSlaveShape | The shape to be used on the slave instance
http_port | The port to use for HTTP traffic to Jenkins
jnlp_port | The Port to use for Jenkins master to slave communication between instances
plugins | The list of plugins to pre-install on the master instance.


<---- to be added ----->



## Known issues and limitations
<  ------------- to be added ------------ >


## Contributing
This project is open source. Oracle appreciates any contributions that are made by the open source community.
See Contributing for details.
