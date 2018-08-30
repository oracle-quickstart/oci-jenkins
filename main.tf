############################################
# Jenkins Master Instance
############################################
module "jenkins-master" {
  source              = "./modules/instances/jenkins-master"
  availability_domain = "${var.master_ad}"
  compartment_ocid    = "${var.compartment_ocid}"
  master_display_name = "${var.master_display_name}"
  image_id            = "${var.master_image_id}"
  shape               = "${var.master_shape}"
  label_prefix        = "${var.label_prefix}"
  subnet_id           = "${var.master_subnet_id}"
  http_port           = "${var.http_port}"
  jnlp_port           = "${var.jnlp_port}"
  ssh_authorized_keys = "${var.ssh_authorized_keys}"
  ssh_private_key     = "${var.ssh_private_key}"
  user_data           = "${var.master_user_data}"
  plugins             = "${var.plugins}"
}

############################################
# Jenkins Slave Instance(s)
############################################
module "jenkins-slave" {
  source               = "./modules/instances/jenkins-slave"
  number_of_slaves     = "${var.slave_count}"
  availability_domains = "${var.slave_ads}"
  compartment_ocid     = "${var.compartment_ocid}"
  slave_display_name   = "${var.slave_display_name}"
  image_id             = "${var.slave_image_id}"
  shape                = "${var.slave_shape}"
  label_prefix         = "${var.label_prefix}"
  subnet_ids           = "${var.slave_subnet_ids}"
  jenkins_master_ip    = "${module.jenkins-master.private_ip}"
  jenkins_master_port  = "${var.http_port}"
  ssh_authorized_keys  = "${var.ssh_authorized_keys}"
  ssh_private_key      = "${var.ssh_private_key}"
}
