# ---------------------------------------------------------------------------------------------------------------------
# This is an example of how to use the terraform_oci_jenkins module to deploy a Jenkins cluster in OCI.
# ---------------------------------------------------------------------------------------------------------------------
provider "oci" {
  tenancy_ocid     = "${var.tenancy_ocid}"
  user_ocid        = "${var.user_ocid}"
  fingerprint      = "${var.fingerprint}"
  private_key_path = "${var.private_key_path}"
  region           = "${var.region}"
}

# ---------------------------------------------------------------------------------------------------------------------
# USING EXISTING VCN AND SUBNET FOR JEKNIS DEPOLYMENT
# Using the public subnets makes this example easy to run and test, but it means Jeknins Master and Slave are
# accessible from the public Internet. In a production deployment, we strongly recommend deploying into a custom AD
# and private subnets.
# ---------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE JENKINS CLUSTER
# ---------------------------------------------------------------------------------------------------------------------
module "jenkins" {
  source              = "../../"
  compartment_ocid    = "${var.compartment_ocid}"
  master_ad           = "${var.master_ad}"
  master_subnet_id    = "${var.master_subnet_id}"
  http_port           = "${var.http_port}"
  slave_count         = "${var.slave_count}"
  slave_ads           = "${var.slave_ads}"
  slave_subnet_ids    = "${var.slave_subnet_ids}"
  ssh_authorized_keys = "${var.ssh_authorized_keys}"
  ssh_private_key     = "${var.ssh_private_key}"
}
