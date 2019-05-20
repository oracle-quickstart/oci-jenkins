# oci-quickstart-jenkins

These are Terraform modules that deploy Jenkins on Oracle Cloud Infrastructure (OCI).

## About
The Jenkins Oracle Cloud Infrastructure Module installs a Terraform-based Jenkins cluster on Oracle Cloud Infrastructure (OCI). A Jenkins cluster typically involves one or more master instance coupled with one or more slave instances.

## Prerequisites
1. See the [Oracle Cloud Infrastructure Terraform Provider docs](https://www.terraform.io/docs/providers/oci/index.html) for information about setting up and using the Oracle Cloud Infrastructure Terraform Provider.
2. An existing VCN with subnets The subnets need internet access in order to download Java and Jenkins.

## What's a Module?
A module is a canonical, reusablem definition for how to run a single piece of infrastructure, such as a database or server cluster. Each module is created using Terraform, and includes automated tests, examples, and documentation. It is maintained both by the open source community and companies that provide commercial support.

Instead of figuring out the details of how to run a piece of infrastructure from scratch, you can reuse existing code that has been proven in production. And instead of maintaining all that infrastructure code yourself, you can leverage the work of the module community to pick up infrastructure improvements through a version number bump.

## How to use this Module
Each Module has the following folder structure:
* [root](): Contains a root module calls jenkins-master and jenkins-slave sub-modules to create a Jenkins cluster in OCI.
* [modules](): Contains the reusable code for this module, broken down into one or more modules.
* [examples](): Contains examples of how to use the modules.

The following code shows how to deploy Jenkins Cluster servers using this module:

```txt
module "jenkins" {
  source              = "git::ssh://git@bitbucket.aka.lgl.grungy.us:7999/tfs/terraform-oci-jenkins.git?ref=dev"
  compartment_ocid    = "${var.compartment_ocid}"
  master_ad           = "${var.master_ad}"
  master_subnet_id    = "${var.master_subnet_id}"
  slave_count         = "${var.slave_count}"
  slave_ads           = "${var.slave_ads}"
  slave_subnet_id     = "${var.slave_subnet_id}"
  ssh_authorized_keys = "${var.ssh_authorized_keys}"
  ssh_private_key     = "${var.ssh_private_key}"
  bastion_host         = "${var.bastion_public_ip}"
  bastion_user         = "${var.bastion_user}"
  bastion_private_key  = "${var.bastion_private_key}"
}

```

Argument | Description
--- | ---
compartment_ocid | OCID of the compartment where VCN will be created.
ssh_authorized_keys | Public SSH keys path to be included in the `~/.ssh/authorized_keys` file for the default user on the instance.
ssh_private_key | Private key path to access the instance.
label_prefix | Used to create unique identifiers to differentiate  multiple clusters in a compartment.
master_ad  | Availability domain for Jenkins master.
master_subnet_id | OCID of the master subnet in which to create the VNIC.
master_display_name | Name of the master instance.
master_image_id | OCID of an image for a master instance to use. For more information, see [Oracle Cloud Infrastructure: Images](https://docs.cloud.oracle.com/iaas/images/).
master_shape | Shape to be used on the master instance.
master_user_data | Provide your own base64-encoded data to be used by `Cloud-Init` to run custom scripts or provide custom `Cloud-Init` configuration for master instance.
slave_count | Number of slave instances to launch.
slave_ads | List of availability domains for Jenkins slave.
slave_subnet_ids | List of Jenkins slave subnet IDs.
slave_display_name | Name of the slave instance.
slave_image_id | OCID of an image for use by the slave instance. For more information, see see [Oracle Cloud Infrastructure: Images](https://docs.cloud.oracle.com/iaas/images/).
slave_shape | Shape to be used on the slave instance.
http_port | Port for HTTP traffic to Jenkins.
jnlp_port | Port for Jenkins master-to-slave communication between instances.
plugins | List of plugins to pre-install on the master instance.
