# OCI Service
variable "tenancy_ocid" {}

variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}

variable "compartment_ocid" {}
variable "ssh_public_key" {}
variable "ssh_private_key" {}

variable "network_cidrs" {
  type = "map"

  default = {
    VCN-CIDR        = "10.0.0.0/16"
    PublicSubnetAD1 = "10.0.10.0/24"
    PublicSubnetAD2 = "10.0.11.0/24"
    PublicSubnetAD3 = "10.0.12.0/24"
    masterSubnetAD1 = "10.0.20.0/24"
    masterSubnetAD2 = "10.0.21.0/24"
    masterSubnetAD3 = "10.0.22.0/24"
    slaveSubnetAD1  = "10.0.30.0/24"
    slaveSubnetAD2  = "10.0.31.0/24"
    slaveSubnetAD3  = "10.0.32.0/24"
  }
}

variable "domain_name" {
  default = "ocijenkins.oraclevcn.com"
}

variable "vcn_dns_name" {
  default = "ocijenkins"
}

variable "label_prefix" {
  description = "To create unique identifier for multiple clusters in a compartment."
  type        = "string"
  default     = ""
}

variable "master_ol_image_name" {
  default = "Oracle-Linux-7.4-2018.02.21-1"
}

variable "slave_ol_image_name" {
  default = "Oracle-Linux-7.4-2018.02.21-1"
}

variable "jenkinsMasterShape" {
  default = "VM.Standard1.1"
}

variable "jenkinsSlaveShape" {
  default = "VM.Standard1.2"
}

# Jenkins Config
variable "http_port" {
  description = "The port to use for HTTP traffic to Jenkins"
  default     = 8080
}

variable "jnlp_port" {
  description = "The Port to use for Jenkins master to slave communication bewtween instances"
  default     = 49187
}

variable "plugins" {
  type        = "list"
  description = "A list of Jenkins plugins to install, use short names."
  default     = ["git"]
}
