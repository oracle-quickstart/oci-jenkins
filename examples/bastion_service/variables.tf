## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}
variable "compartment_ocid" {}
variable "ssh_authorized_keys" {}
variable "ssh_private_key" {}

variable "vcn_cidr" {
  default = "10.0.0.0/16"
}

locals {
  // contains bastion, LB, and anything internet-facing
  dmz_tier_prefix = cidrsubnet(var.vcn_cidr, 2, 0)

  // contains private subnets with app logic
  app_tier_prefix = cidrsubnet(var.vcn_cidr, 2, 1)

  lb_subnet_prefix         = cidrsubnet(local.dmz_tier_prefix, 2, 0)
  bastion_subnet_prefix    = cidrsubnet(local.dmz_tier_prefix, 2, 1)
  controller_subnet_prefix = cidrsubnet(local.app_tier_prefix, 2, 0)
  agent_subnet_prefix      = cidrsubnet(local.app_tier_prefix, 2, 1)
}

variable "label_prefix" {
  default = ""
}

variable "http_port" {
  default = 8080
}

variable "jnlp_port" {
  default = 49187
}

variable "lb_shape" {
  default = "flexible"
}

variable "flex_lb_min_shape" {
  default = "10"
}

variable "flex_lb_max_shape" {
  default = "100"
}

variable "plugins" {
  type        = list(string)
  description = "A list of Jenkins plugins to install, use short names. "
  default     = ["git", "ssh-slaves", "oracle-cloud-infrastructure-compute"]
}

variable "jenkins_version" {
  default = "2.277.4"
}

variable "jenkins_password" {
}

variable "agent_count" {
  default = "2"
}

variable "controller_shape" {
  default = "VM.Standard.E3.Flex"
}

variable "controller_flex_shape_ocpus" {
  description = "Number of Flex shape OCPUs"
  default     = 1
}

variable "controller_flex_shape_memory" {
  description = "Amount of Flex shape Memory in GB"
  default     = 10
}

variable "agent_shape" {
  default = "VM.Standard.E3.Flex"
}

variable "agent_flex_shape_ocpus" {
  description = "Number of Flex shape OCPUs"
  default     = 1
}

variable "agent_flex_shape_memory" {
  description = "Amount of Flex shape Memory in GB"
  default     = 10
}

variable "bastion_private_key" {
}

variable "bastion_authorized_keys" {
}

variable "listener_ca_certificate" {
  default = ""
}

variable "listener_private_key" {
  default = ""
}

variable "listener_public_certificate" {
  default = ""
}

variable "instance_os" {
  description = "Operating system for compute instances"
  default     = "Oracle Linux"
}

variable "linux_os_version" {
  description = "Operating system version for all Linux instances"
  default     = "7.9"
}
