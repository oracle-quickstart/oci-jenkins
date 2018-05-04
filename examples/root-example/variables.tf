variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}
variable "compartment_ocid" {}
variable "ssh_authorized_keys" {}
variable "ssh_private_key" {}

variable "network_cidrs" {
  type = "map"

  default = {
    VCN-CIDR       = "10.0.0.0/16"
    masterSubnetAD = "10.0.20.0/24"
    slaveSubnetAD1 = "10.0.30.0/24"
    slaveSubnetAD2 = "10.0.31.0/24"
    slaveSubnetAD3 = "10.0.32.0/24"
  }
}

variable "label_prefix" {
  default = ""
}

variable "master_ad" {}
variable "master_image_id" {}

variable "slave_ads" {
  type = "list"
}

variable "slave_image_id" {}

variable "http_port" {
  default = 8080
}

variable "jnlp_port" {
  default = 49187
}
