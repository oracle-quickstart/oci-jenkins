# ------------------------------------------------------------------------------
# Setup Bastion Service
# ------------------------------------------------------------------------------
resource "oci_bastion_bastion" "bastion-service" {
  bastion_type                 = "STANDARD"
  compartment_id               = var.compartment_ocid
  target_subnet_id             = oci_core_subnet.JenkinsBastion.id
  client_cidr_block_allow_list = ["0.0.0.0/0"]
  name                         = "BastionService"
  max_session_ttl_in_seconds   = 1800
}

# ------------------------------------------------------------------------------
# DEPLOY THE JENKINS CLUSTER
# ------------------------------------------------------------------------------
module "jenkins" {
  source                       = "../../"
  compartment_ocid             = var.compartment_ocid
  jenkins_version              = var.jenkins_version
  jenkins_password             = var.jenkins_password
  controller_ad                = data.template_file.ad_names[0].rendered
  controller_subnet_id         = oci_core_subnet.JenkinsControllerSubnetAD.id
  controller_image_id          = lookup(data.oci_core_images.controller_image.images[0], "id")
  controller_shape             = var.controller_shape
  controller_flex_shape_ocpus  = var.controller_flex_shape_ocpus
  controller_flex_shape_memory = var.controller_flex_shape_memory
  plugins                      = var.plugins
  agent_count                  = var.agent_count
  agent_ads                    = data.template_file.ad_names.*.rendered
  agent_subnet_ids             = split(",", join(",", oci_core_subnet.JenkinsAgentSubnetAD.*.id))
  agent_image_id               = lookup(data.oci_core_images.agent_image.images[0], "id")
  agent_shape                  = var.agent_shape
  agent_flex_shape_ocpus       = var.agent_flex_shape_ocpus
  agent_flex_shape_memory      = var.agent_flex_shape_memory
  ssh_authorized_keys          = file(var.ssh_authorized_keys)
  ssh_private_key              = file(var.ssh_private_key)
  use_bastion_service          = true
  bastion_service_id           = oci_bastion_bastion.bastion-service.id
  bastion_service_region       = var.region
  bastion_host                 = ""
  bastion_private_key          = file(var.bastion_private_key)
  bastion_authorized_keys      = file(var.bastion_authorized_keys)
}

