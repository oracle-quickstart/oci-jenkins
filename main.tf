## PROVIDER
provider "oci" {
  tenancy_ocid         = "${var.tenancy_ocid}"
  user_ocid            = "${var.user_ocid}"
  fingerprint          = "${var.fingerprint}"
  private_key_path     = "${var.private_key_path}"
  region               = "${var.region}"
  disable_auto_retries = "true"
}

data "oci_identity_availability_domains" "ADs" {
  compartment_id = "${var.tenancy_ocid}"
}

## Virtual Cloud Network
module "vcn" {
  source           = "./modules/network/vcn"
  compartment_ocid = "${var.compartment_ocid}"
  label_prefix     = "${var.label_prefix}"
  tenancy_ocid     = "${var.tenancy_ocid}"
  vcn_dns_name     = "${var.vcn_dns_name}"
  network_cidrs    = "${var.network_cidrs}"
  http_port        = "${var.http_port}"
  jnlp_port        = "${var.jnlp_port}"
}

## COMPUTE INSTANCE(S)
# Jenkins Master Instance
module "jenkins-master-ad1" {
  source                  = "./modules/instances/jenkins-master"
  availability_domain     = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0],"name")}"
  compartment_ocid        = "${var.compartment_ocid}"
  display_name_prefix     = "jenkins-master-ad1"
  hostname_label_prefix   = "jenkins-master-ad1"
  oracle_linux_image_name = "${var.master_ol_image_name}"
  shape                   = "${var.jenkinsMasterShape}"
  label_prefix            = "${var.label_prefix}"
  tenancy_ocid            = "${var.compartment_ocid}"
  network_cidrs           = "${var.network_cidrs}"
  subnet_id               = "${module.vcn.jenkinsmaster_subnet_ad1_id}"
  subnet_name             = "masterSubnetAD1"
  http_port               = "${var.http_port}"
  jnlp_port               = "${var.jnlp_port}"
  ssh_public_key          = "${var.ssh_public_key}"
  ssh_private_key         = "${var.ssh_private_key}"
  user_data               = ""
  setup_data              = "${data.template_file.setup_data_master.rendered}"
}

data "template_file" "setup_data_master" {
  template = "${file("./modules/instances/jenkins-master/scripts/setup.sh")}"

  vars = {
    http_port = "${var.http_port}"
    jnlp_port = "${var.jnlp_port}"
    plugins   = "${join(" ", var.plugins)}"
  }
}

# Jenkins Slave Instance(s)
module "jenkins-slave-ad1" {
  source                  = "./modules/instances/jenkins-slave"
  count                   = "${var.slaveAd1Count}"
  availability_domain     = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0],"name")}"
  compartment_ocid        = "${var.compartment_ocid}"
  display_name_prefix     = "jenkins-slave-ad1"
  hostname_label_prefix   = "jenkins-slave-ad1"
  oracle_linux_image_name = "${var.slave_ol_image_name}"
  shape                   = "${var.jenkinsSlaveShape}"
  label_prefix            = "${var.label_prefix}"
  tenancy_ocid            = "${var.compartment_ocid}"
  subnet_id               = "${module.vcn.jenkinsslave_subnet_ad1_id}"
  jenkins_master_ip       = "${element(concat(flatten(module.jenkins-master-ad1.private_ips), list("")), 0)}"
  jenkins_master_port     = "${var.http_port}"
  ssh_public_key          = "${var.ssh_public_key}"
  ssh_private_key         = "${var.ssh_private_key}"
  private_key_path        = "${var.private_key_path}"
}
