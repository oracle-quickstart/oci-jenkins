############################################
# Jenkins Master Instance
############################################
module "jenkins-master" {
  source                = "./modules/jenkins-master"
  availability_domain   = "${var.master_ad}"
  compartment_ocid      = "${var.compartment_ocid}"
  master_display_name   = "${var.master_display_name}"
  image_id              = "${var.master_image_id}"
  shape                 = "${var.master_shape}"
  label_prefix          = "${var.label_prefix}"
  subnet_id             = "${var.master_subnet_id}"
  jenkins_version       = "${var.jenkins_version}"
  jenkins_password      = "${var.jenkins_password}"
  http_port             = "${var.http_port}"
  jnlp_port             = "${var.jnlp_port}"
  ssh_authorized_keys   = "${var.ssh_authorized_keys}"
  ssh_private_key       = "${var.ssh_private_key}"
  user_data             = "${var.master_user_data}"
  plugins               = "${var.plugins}"
  bastion_host          = "${var.bastion_host}"
  bastion_user          = "${var.bastion_user}"
  bastion_private_key   = "${var.bastion_private_key}"
}

############################################
# Jenkins agent Instance(s)
############################################
module "jenkins-agent" {
  source                = "./modules/jenkins-agent"
  number_of_agents      = "${var.agent_count}"
  availability_domains  = "${var.agent_ads}"
  compartment_ocid      = "${var.compartment_ocid}"
  agent_display_name    = "${var.agent_display_name}"
  image_id              = "${var.agent_image_id}"
  shape                 = "${var.agent_shape}"
  label_prefix          = "${var.label_prefix}"
  subnet_ids            = "${var.agent_subnet_ids}"
  jenkins_master_ip     = "${module.jenkins-master.private_ip}"
  jenkins_master_port   = "${var.http_port}"
  jenkins_password      = "${var.jenkins_password}"
  ssh_authorized_keys   = "${var.ssh_authorized_keys}"
  ssh_private_key       = "${var.ssh_private_key}"
  bastion_host          = "${var.bastion_host}"
  bastion_user          = "${var.bastion_user}"
  bastion_private_key   = "${var.bastion_private_key}"
}
