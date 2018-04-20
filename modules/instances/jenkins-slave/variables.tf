# OCI service
variable "availability_domain" {}

variable "compartment_ocid" {}
variable "display_name_prefix" {}
variable "hostname_label_prefix" {}

variable "subnet_id" {
  description = "ID of subnet to use for master instance(s)"
}

variable "shape" {}
variable "tenancy_ocid" {}

variable "label_prefix" {
  default = ""
}

# Instance
variable "count" {
  description = "The number of slave instance(s) to create"
}

variable "jenkins_master_ip" {
  description = "The IP of the master jenkins instance"
}

variable "jenkins_master_port" {
  description = "The Port of the master jenkins instance"
}

variable "ssh_public_key" {}

variable "ssh_private_key" {}

variable "private_key_path" {}

variable "oracle_linux_image_name" {
  default = "Oracle-Linux-7.4-2018.01.20-0"
}

variable "environment" {
  description = "The environement tag to add to Jenkins master instance"
  default     = ""
}

variable "tags" {
  type        = "map"
  description = "Supply tags you want added to all resources"
  default     = {}
}
