# ---------------------------------------------------------------------------------------------------------------------
# Setup Bastion Host
# ---------------------------------------------------------------------------------------------------------------------
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

# ---------------------------------------------------------------------------------------------------------------------
# Setup NAT Host
# ---------------------------------------------------------------------------------------------------------------------
resource "oci_core_instance" "JenkinsNat" {
  availability_domain = "${data.template_file.ad_names.*.rendered[var.nat_ad_index]}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "${var.nat_display_name}"
  shape               = "${var.nat_shape}"

  create_vnic_details {
    subnet_id              = "${oci_core_subnet.JenkinsNat.id}"
    skip_source_dest_check = true
  }

  metadata {
    ssh_authorized_keys = "${file("${var.nat_authorized_keys}")}"
    user_data           = "${base64encode(file("nat_user_data.tpl"))}"
  }

  source_details {
    source_id   = "${var.image_id[var.region]}"
    source_type = "image"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE JENKINS CLUSTER
# ---------------------------------------------------------------------------------------------------------------------
module "jenkins" {
  source              = "../"
  compartment_ocid    = "${var.compartment_ocid}"
  jenkins_version     = "2.138.1"
  master_ad           = "${data.template_file.ad_names.*.rendered[0]}"
  master_subnet_id    = "${oci_core_subnet.JenkinsMasterSubnetAD.id}"
  master_image_id     = "${var.image_id[var.region]}"
  slave_count         = "2"
  slave_ads           = "${data.template_file.ad_names.*.rendered}"
  slave_subnet_ids    = "${split(",",join(",", oci_core_subnet.JenkinsSlaveSubnetAD.*.id))}"
  slave_image_id      = "${var.image_id[var.region]}"
  ssh_authorized_keys = "${var.ssh_authorized_keys}"
  ssh_private_key     = "${var.ssh_private_key}"
  bastion_host         = "${oci_core_instance.JenkinsBastion.public_ip}"
  bastion_user         = "${var.bastion_user}"
  bastion_private_key  = "${var.bastion_private_key}"
}
