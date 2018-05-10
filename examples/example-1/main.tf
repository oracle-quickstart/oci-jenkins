# ---------------------------------------------------------------------------------------------------------------------
# This is an example of how to use the terraform_oci_jenkins module to deploy a Jenkins cluster in OCI by using
# existing VCN, Security list and Subnets.
# ---------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------------
# PROVIDER
# ---------------------------------------------------------------------------------------------------------------------
provider "oci" {
  tenancy_ocid     = "${var.tenancy_ocid}"
  user_ocid        = "${var.user_ocid}"
  fingerprint      = "${var.fingerprint}"
  private_key_path = "${var.private_key_path}"
  region           = "${var.region}"
}

# ---------------------------------------------------------------------------------------------------------------------
# DATASOURCE
# ---------------------------------------------------------------------------------------------------------------------
# Gets a list of Availability Domains
data "oci_identity_availability_domains" "ad" {
  compartment_id = "${var.tenancy_ocid}"
}

data "template_file" "ad_names" {
  count    = "${length(data.oci_identity_availability_domains.ad.availability_domains)}"
  template = "${lookup(data.oci_identity_availability_domains.ad.availability_domains[count.index], "name")}"
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE JENKINS CLUSTER
# ---------------------------------------------------------------------------------------------------------------------
module "jenkins" {
  source              = "../../"
  compartment_ocid    = "${var.compartment_ocid}"
  master_ad           = "${data.template_file.ad_names.*.rendered[0]}"
  master_subnet_id    = "${var.master_subnet_id}"
  master_image_id     = "${var.image_id[var.region]}"
  http_port           = "8989"
  jnlp_port           = "49187"
  slave_count         = "2"
  slave_ads           = "${data.template_file.ad_names.*.rendered}"
  slave_subnet_ids    = "${var.slave_subnet_ids}"
  slave_image_id      = "${var.image_id[var.region]}"
  ssh_authorized_keys = "${var.ssh_authorized_keys}"
  ssh_private_key     = "${var.ssh_private_key}"
  plugins             = ["git", "ssh-slaves", "oracle-cloud-infrastructure-compute"]
}

# ---------------------------------------------------------------------------------------------------------------------
# VARIABLES
# ---------------------------------------------------------------------------------------------------------------------
variable "tenancy_ocid" {}

variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}
variable "compartment_ocid" {}
variable "ssh_authorized_keys" {}
variable "ssh_private_key" {}
variable "master_subnet_id" {}

variable "slave_subnet_ids" {
  type = "list"
}

variable "image_id" {
  type = "map"

  # --------------------------------------------------------------------------
  # Oracle-provided image "Oracle-Linux-7.4-2018.02.21-1"
  # See https://docs.us-phoenix-1.oraclecloud.com/images/
  # --------------------------------------------------------------------------
  default = {
    us-phoenix-1   = "ocid1.image.oc1.phx.aaaaaaaaupbfz5f5hdvejulmalhyb6goieolullgkpumorbvxlwkaowglslq"
    us-ashburn-1   = "ocid1.image.oc1.iad.aaaaaaaajlw3xfie2t5t52uegyhiq2npx7bqyu4uvi2zyu3w3mqayc2bxmaa"
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaa7d3fsb6272srnftyi4dphdgfjf6gurxqhmv6ileds7ba3m2gltxq"
    uk-london-1    = "ocid1.image.oc1.uk-london-1.aaaaaaaaa6h6gj6v4n56mqrbgnosskq63blyv2752g36zerymy63cfkojiiq"
  }
}
