# OCI service
variable "compartment_ocid" {
  description = "Compartment's OCID where VCN will be created. "
}

variable "availability_domain" {
  description = "The Availability Domain of the instance. "
  default     = ""
}

variable "master_display_name" {
  description = "The name of the master instance. "
  default     = ""
}

variable "subnet_id" {
  description = "The OCID of the master subnet to create the VNIC in. "
  default     = ""
}

variable "shape" {
  description = "Instance shape to use for master instance. "
  default     = ""
}

variable "label_prefix" {
  description = "To create unique identifier for multiple clusters in a compartment."
  default = ""
}

variable "assign_public_ip" {
  description = "Whether the VNIC should be assigned a public IP address. Defaults to whether the subnet is public or private. "
  default     = true
}

variable "ssh_authorized_keys" {
  description = "Public SSH keys path to be included in the ~/.ssh/authorized_keys file for the default user on the instance. "
  default     = ""
}

variable "ssh_private_key" {
  description = "The private key path to access instance. "
  default     = ""
}

variable "master_ol_image_name" {
  description = "The image name of a master instance. "
  default = ""
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
