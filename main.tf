# ------------------------------------------------------------------------------
# Setup Bastion Host
# ------------------------------------------------------------------------------
resource "oci_core_instance" "JenkinsBastion" {
  availability_domain = data.template_file.ad_names[var.bastion_ad_index].rendered
  compartment_id      = var.compartment_ocid
  display_name        = var.bastion_display_name
  shape               = var.bastion_shape

  create_vnic_details {
    subnet_id        = oci_core_subnet.JenkinsBastion.id
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = tls_private_key.public_private_key_pair.public_key_openssh
  }

  source_details {
    source_id   = var.image_id[var.region]
    source_type = "image"
  }
}

# ------------------------------------------------------------------------------
# DEPLOY THE JENKINS CLUSTER
# ------------------------------------------------------------------------------
module "jenkins" {
  source              = "./modules/jenkins"
  compartment_ocid    = var.compartment_ocid
  jenkins_version     = var.jenkins_version
  jenkins_password    = var.jenkins_password
  master_ad           = data.template_file.ad_names[0].rendered
  master_subnet_id    = oci_core_subnet.JenkinsMasterSubnetAD.id
  master_image_id     = var.image_id[var.region]
  master_shape        = var.master_shape
  plugins             = var.plugins
  slave_count         = var.slave_count
  slave_ads           = data.template_file.ad_names.*.rendered
  slave_subnet_ids    = split(",", join(",", oci_core_subnet.JenkinsSlaveSubnetAD.*.id))
  slave_image_id      = var.image_id[var.region]
  slave_shape         = var.slave_shape
  ssh_authorized_keys = tls_private_key.public_private_key_pair.public_key_openssh
  ssh_private_key     = tls_private_key.public_private_key_pair.private_key_pem
  bastion_host        = oci_core_instance.JenkinsBastion.public_ip
  bastion_user        = var.bastion_user
  bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
  http_port           = var.http_port
}

