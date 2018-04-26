############################################
# Jenkins Master Instance
############################################
module "jenkins-master" {
  source               = "./modules/instances/jenkins-master"
  availability_domain  = "${var.master_ad}"
  compartment_ocid     = "${var.compartment_ocid}"
  master_display_name  = "${var.master_display_name}"
  master_ol_image_name = "${var.master_ol_image_name}"
  shape                = "${var.master_shape}"
  label_prefix         = "${var.label_prefix}"
  subnet_id            = "${var.master_subnet_id}"
  http_port            = "${var.http_port}"
  jnlp_port            = "${var.jnlp_port}"
  ssh_authorized_keys  = "${var.ssh_authorized_keys}"
  ssh_private_key      = "${var.ssh_private_key}"
  user_data            = "${var.master_user_data}"
  setup_data           = "${data.template_file.setup_data_master.rendered}"
}

data "template_file" "setup_data_master" {
  template = "${file("${path.module}/modules/instances/jenkins-master/scripts/setup.sh")}"

  vars = {
    http_port = "${var.http_port}"
    jnlp_port = "${var.jnlp_port}"
    plugins   = "${join(" ", var.plugins)}"
  }
}

############################################
# Jenkins Slave Instance(s)
############################################
module "jenkins-slave" {
  source               = "./modules/instances/jenkins-slave"
  count                = "${var.slave_count}"
  availability_domains = "${var.slave_ads}"
  compartment_ocid     = "${var.compartment_ocid}"
  slave_display_name   = "${var.slave_display_name}"
  slave_ol_image_name  = "${var.slave_ol_image_name}"
  shape                = "${var.slave_shape}"
  label_prefix         = "${var.label_prefix}"
  subnet_ids           = "${var.slave_subnet_ids}"
  jenkins_master_ip    = "${element(concat(flatten(module.jenkins-master.private_ips), list("")), 0)}"
  jenkins_master_port  = "${var.http_port}"
  ssh_authorized_keys  = "${var.ssh_authorized_keys}"
  ssh_private_key      = "${var.ssh_private_key}"
}
