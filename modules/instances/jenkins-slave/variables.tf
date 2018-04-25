# OCI service
variable "compartment_ocid" {
  description = "Compartment's OCID where VCN will be created. "
}

variable "availability_domains" {
  description = "The Availability Domains of the slave instance. "
  default     = []
}

variable "subnet_ids" {
  description = "List of Jenkins slave subnets' id. "
  default     = []
}

variable "slave_display_name" {
  description = "The name of the slave instance. "
  default     = ""
}

variable "shape" {
  description = "Instance shape to use for slave instance. "
  default     = ""
}

variable "label_prefix" {
  description = "To create unique identifier for multiple clusters in a compartment."
  default = ""
}

variable "count" {
  description = "The number of slave instance(s) to create"
}

variable "jenkins_master_ip" {
  description = "The IP of the master jenkins instance"
}

variable "jenkins_master_port" {
  description = "The Port of the master jenkins instance"
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

variable "slave_ol_image_name" {
  description = "The image name of a slave instance. "
  default = ""
}
