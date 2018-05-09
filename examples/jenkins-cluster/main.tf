# ---------------------------------------------------------------------------------------------------------------------
# This is an example of how to use the terraform_oci_jenkins module to deploy a Jenkins cluster in OCI.
# ---------------------------------------------------------------------------------------------------------------------
variable "tenancy_ocid" {}

variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}
variable "compartment_ocid" {}
variable "ssh_authorized_keys" {}
variable "ssh_private_key" {}
variable "master_ad" {}
variable "master_subnet_id" {}
variable "master_image_id" {}

variable "slave_ads" {
  type = "list"
}

variable "slave_subnet_ids" {
  type = "list"
}

variable "slave_image_id" {}

provider "oci" {
  tenancy_ocid     = "${var.tenancy_ocid}"
  user_ocid        = "${var.user_ocid}"
  fingerprint      = "${var.fingerprint}"
  private_key_path = "${var.private_key_path}"
  region           = "${var.region}"
}

# ---------------------------------------------------------------------------------------------------------------------
# USING EXISTING VCN AND SUBNET FOR JEKNIS DEPOLYMENT
# ---------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE JENKINS CLUSTER
# ---------------------------------------------------------------------------------------------------------------------
module "jenkins" {
  source              = "../../"
  compartment_ocid    = "${var.compartment_ocid}"
  master_ad           = "${var.master_ad}"
  master_subnet_id    = "${var.master_subnet_id}"
  master_image_id     = "${var.master_image_id}"
  http_port           = "8989"
  jnlp_port           = "49187"
  slave_count         = "2"
  slave_ads           = "${var.slave_ads}"
  slave_subnet_ids    = "${var.slave_subnet_ids}"
  slave_image_id      = "${var.slave_image_id}"
  ssh_authorized_keys = "${var.ssh_authorized_keys}"
  ssh_private_key     = "${var.ssh_private_key}"
  plugins             = ["git", "oracle-cloud-infrastructure-compute"]
}
