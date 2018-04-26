variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}

variable "compartment_ocid" {
  description = "Compartment's OCID where VCN will be created. "
}

variable "network_cidrs" {
  type = "map"

  default = {
    VCN-CIDR        = "10.0.0.0/16"
    masterSubnetAD = "10.0.20.0/24"
    slaveSubnetAD1  = "10.0.30.0/24"
    slaveSubnetAD2  = "10.0.31.0/24"
    slaveSubnetAD3  = "10.0.32.0/24"
  }
}


variable "dns_label" {
  description = "Allows assignment of DNS hostname when launching an Instance. "
  default     = ""
}

variable "label_prefix" {
  description = "To create unique identifier for multiple clusters in a compartment."
  default     = ""
}

variable "ssh_authorized_keys" {
  description = "Public SSH keys path to be included in the ~/.ssh/authorized_keys file for the default user on the instance. "
  default     = ""
}

variable "ssh_private_key" {
  description = "The private key path to access instance. "
  default     = ""
}

variable "master_ad" {
  description = "The Availability Domain for Jenkins master. "
  default     = ""
}

variable "master_subnet_id" {
  description = "The OCID of the master subnet to create the VNIC in. "
  default     = ""
}

variable "slave_count" {
  description = "Number of slave instances to launch. "
  default     = 1
}

variable "slave_ads" {
  description = "The Availability Domain(s) for Jenkins slave(s). "
  default     = []
}

variable "slave_subnet_ids" {
  description = "List of Jenkins slave subnets' id. "
  default     = []
}

variable "master_ol_image_name" {
  description = "The image name of a master instance. "
  default     = "Oracle-Linux-7.4-2018.02.21-1"
}

variable "slave_ol_image_name" {
  description = "The image name of a slave instance. "
  default     = "Oracle-Linux-7.4-2018.02.21-1"
}

variable "master_shape" {
  description = "Instance shape to use for master instance. "
  default     = "VM.Standard1.1"
}

variable "slave_shape" {
  description = "Instance shape to use for slave instance(s). "
  default     = "VM.Standard1.1"
}

variable "http_port" {
  description = "The port to use for HTTP traffic to Jenkins. "
  default     = 8080
}

variable "jnlp_port" {
  description = "The Port to use for Jenkins master to slave communication bewtween instances. "
  default     = 49187
}

variable "plugins" {
  type        = "list"
  description = "A list of Jenkins plugins to install, use short names. "
  default     = ["git", "ssh-slaves"]
}
