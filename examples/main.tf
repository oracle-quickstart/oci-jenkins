# ------------------------------------------------------------------------------
# Setup Bastion Host
# ------------------------------------------------------------------------------
resource "oci_core_instance" "JenkinsBastion" {
  availability_domain = "${data.template_file.ad_names.*.rendered[var.bastion_ad_index]}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "${var.bastion_display_name}"
  shape               = "${var.bastion_shape}"

  create_vnic_details {
    subnet_id        = "${oci_core_subnet.JenkinsBastion.id}"
    assign_public_ip = true
  }

  metadata {
    ssh_authorized_keys = "${file("${var.bastion_authorized_keys}")}"
  }

  source_details {
    source_id   = "${var.image_id[var.region]}"
    source_type = "image"
  }
}

# ------------------------------------------------------------------------------
# DEPLOY THE JENKINS CLUSTER
# ------------------------------------------------------------------------------
module "jenkins" {
  source                = "../"
  compartment_ocid      = "${var.compartment_ocid}"
  jenkins_version       = "${var.jenkins_version}"
  jenkins_password      = "${var.jenkins_password}"
  master_ad             = "${data.template_file.ad_names.*.rendered[0]}"
  master_subnet_id      = "${oci_core_subnet.JenkinsMasterSubnetAD.id}"
  master_image_id       = "${var.image_id[var.region]}"
  slave_count           = "${var.slave_count}"
  slave_ads             = "${data.template_file.ad_names.*.rendered}"
  slave_subnet_ids      = "${split(",",join(",", oci_core_subnet.JenkinsSlaveSubnetAD.*.id))}"
  slave_image_id        = "${var.image_id[var.region]}"
  ssh_authorized_keys   = "${var.ssh_authorized_keys}"
  ssh_private_key       = "${var.ssh_private_key}"
  bastion_host          = "${oci_core_instance.JenkinsBastion.public_ip}"
  bastion_user          = "${var.bastion_user}"
  bastion_private_key   = "${var.bastion_private_key}"
}
