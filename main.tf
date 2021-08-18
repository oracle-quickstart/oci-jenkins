############################################
# Jenkins Controller Instance
############################################
module "jenkins-controller" {
  source                  = "./modules/jenkins-controller"
  availability_domain     = var.controller_ad
  compartment_ocid        = var.compartment_ocid
  controller_display_name = var.controller_display_name
  image_id                = var.controller_image_id
  shape                   = var.controller_shape
  flex_shape_ocpus        = var.controller_flex_shape_ocpus
  flex_shape_memory       = var.controller_flex_shape_memory
  label_prefix            = var.label_prefix
  subnet_id               = var.controller_subnet_id
  jenkins_version         = var.jenkins_version
  jenkins_password        = var.jenkins_password
  http_port               = var.http_port
  jnlp_port               = var.jnlp_port
  ssh_authorized_keys     = var.ssh_authorized_keys
  ssh_private_key         = var.ssh_private_key
  user_data               = var.controller_user_data
  plugins                 = var.plugins
  use_bastion_service     = var.use_bastion_service
  bastion_host            = var.bastion_host
  bastion_user            = var.bastion_user
  bastion_private_key     = var.bastion_private_key
}

############################################
# Jenkins agent Instance(s)
############################################
module "jenkins-agent" {
  source                  = "./modules/jenkins-agent"
  number_of_agents        = var.agent_count
  availability_domains    = var.agent_ads
  compartment_ocid        = var.compartment_ocid
  agent_display_name      = var.agent_display_name
  image_id                = var.agent_image_id
  shape                   = var.agent_shape
  flex_shape_ocpus        = var.agent_flex_shape_ocpus
  flex_shape_memory       = var.agent_flex_shape_memory
  label_prefix            = var.label_prefix
  subnet_ids              = var.agent_subnet_ids
  jenkins_controller_ip   = module.jenkins-controller.private_ip
  jenkins_controller_port = var.http_port
  jenkins_password        = var.jenkins_password
  ssh_authorized_keys     = var.ssh_authorized_keys
  ssh_private_key         = var.ssh_private_key
  use_bastion_service     = var.use_bastion_service
  bastion_host            = var.bastion_host
  bastion_user            = var.bastion_user
  bastion_private_key     = var.bastion_private_key
}
