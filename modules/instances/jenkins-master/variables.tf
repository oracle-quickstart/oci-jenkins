# OCI service
variable "availability_domain" {}

variable "compartment_ocid" {}
variable "display_name_prefix" {}
variable "hostname_label_prefix" {}

variable "network_cidrs" {
  type = "map"
}

variable "subnet_id" {}
variable "subnet_name" {}
variable "shape" {}
variable "tenancy_ocid" {}

variable "label_prefix" {
  default = ""
}

# Instance
variable "ssh_public_key" {}

variable "ssh_private_key" {}

variable "oracle_linux_image_name" {
  default = "Oracle-Linux-7.4-2018.01.20-0"
}

variable "user_data" {
  description = "A User Data script to execute while the server is booting."
}

variable "setup_data" {
  description = "A User Data script to execute after server has booted to setup jenkins defaults."
}

variable "http_port" {
  description = "The port to use for HTTP traffic to Jenkins"
  default     = 8080
}

variable "https_port" {
  description = "The port to use for HTTPS traffic to Jenkins"
  default     = 443
}

variable "jnlp_port" {
  description = "The port to use for TCP traffic between Jenkins intances"
  default     = 49187
}
