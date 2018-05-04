# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE JENKINS CLUSTER
# ---------------------------------------------------------------------------------------------------------------------
module "jenkins" {
  source              = "../../"
  compartment_ocid    = "${var.compartment_ocid}"
  master_ad           = "${var.master_ad}"
  master_subnet_id    = "${oci_core_subnet.JenkinsMasterSubnetAD.id}"
  master_image_id     = "${var.master_image_id}"
  slave_count         = "2"
  slave_ads           = "${var.slave_ads}"
  slave_subnet_ids    = "${split(",",join(",", oci_core_subnet.JenkinsSlaveSubnetAD.*.id))}"
  slave_image_id      = "${var.slave_image_id}"
  ssh_authorized_keys = "${var.ssh_authorized_keys}"
  ssh_private_key     = "${var.ssh_private_key}"
}
