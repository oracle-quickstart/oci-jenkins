# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE JENKINS CLUSTER
# ---------------------------------------------------------------------------------------------------------------------
module "jenkins" {
  source              = "../../"
  compartment_ocid    = "${var.compartment_ocid}"
  master_ad           = "${data.template_file.ad_names.*.rendered[0]}"
  master_subnet_id    = "${oci_core_subnet.JenkinsMasterSubnetAD.id}"
  master_image_id     = "${var.image_id[var.region]}"
  slave_count         = "2"
  slave_ads           = "${data.template_file.ad_names.*.rendered}"
  slave_subnet_ids    = "${split(",",join(",", oci_core_subnet.JenkinsSlaveSubnetAD.*.id))}"
  slave_image_id      = "${var.image_id[var.region]}"
  ssh_authorized_keys = "${var.ssh_authorized_keys}"
  ssh_private_key     = "${var.ssh_private_key}"
}
