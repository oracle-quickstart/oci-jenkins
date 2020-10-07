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
# Jenkins Slave Instance(s)
############################################
module "jenkins-slave" {
  source                = "./modules/jenkins-slave"
  number_of_slaves      = "${var.slave_count}"
  availability_domains  = "${var.slave_ads}"
  compartment_ocid      = "${var.compartment_ocid}"
  slave_display_name    = "${var.slave_display_name}"
  image_id              = "${var.slave_image_id}"
  shape                 = "${var.slave_shape}"
  label_prefix          = "${var.label_prefix}"
  subnet_ids            = "${var.slave_subnet_ids}"
  jenkins_master_ip     = "${module.jenkins-master.private_ip}"
  jenkins_master_port   = "${var.http_port}"
  jenkins_password      = "${var.jenkins_password}"
  ssh_authorized_keys   = "${var.ssh_authorized_keys}"
  ssh_private_key       = "${var.ssh_private_key}"
  bastion_host          = "${var.bastion_host}"
  bastion_user          = "${var.bastion_user}"
  bastion_private_key   = "${var.bastion_private_key}"
}
