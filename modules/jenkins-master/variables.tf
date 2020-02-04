variable "compartment_ocid" {
  description = "Compartment's OCID where VCN will be created. "
  default = "ocid1.compartment.oc1..aaaaaaaada2gaukcqoagqoshxq2pyt6cdsj2mhnrz3p5nke33ljx2bp476wq"
}

variable "availability_domain" {
  description = "The Availability Domain of the instance. "
  default     = ""
}

variable "jenkins_version" {
  description = "The version of the Jenkins Server."
  default     = "2.138.2"
}

variable "jenkins_password" {
  description = "Required field for Jenkins initial password. "
  default = "Oracle1234!!!!"
}

variable "master_display_name" {
  description = "The name of the master instance. "
  default     = "Jenkins_Master"
}

variable "subnet_id" {
  description = "The OCID of the master subnet to create the VNIC in. "
  default     = "ocid1.subnet.oc1.iad.aaaaaaaa5hkgodv25wtxwptoklrwvmzji2urka6yqwac2sizxfw45atcf4qa"
}

variable "shape" {
  description = "Instance shape to use for master instance. "
  default     = "VM.Standard1.4"
}

variable "label_prefix" {
  description = "To create unique identifier for multiple clusters in a compartment."
  default     = ""
}

variable "assign_public_ip" {
  description = "Whether the VNIC should be assigned a public IP address."
  default     = "True"
}

variable "ssh_authorized_keys" {
  description = "Public SSH keys path to be included in the ~/.ssh/authorized_keys file for the default user on the instance. "
  default     = "/home/opc/.ssh/id_rsa.pub"
}

variable "ssh_private_key" {
  description = "The private key path to access instance. "
  default     = "/home/opc/.ssh/id_rsa"
}

variable "image_id" {
  description = "The OCID of an image for an instance to use. "
  default     = "ocid1.image.oc1.iad.aaaaaaaaxrcvnpfxfsyzv3ytuu6swalnbmocneej6yj4nr4vbcoufgmfpwqq"
}

variable "user_data" {
  description = "A User Data script to execute while the server is booting."
}

variable "http_port" {
  description = "The port to use for HTTP traffic to Jenkins"
  default = "8080"
}

variable "jnlp_port" {
  description = "The port to use for TCP traffic between Jenkins intances"
}

variable "plugins" {
  type        = list(string)
  description = "A list of Jenkins plugins to install, use short names. "
}

variable "bastion_host" {
  description = "The bastion host IP."
}

variable "bastion_user" {
  description = "The SSH user to connect to the bastion host."
  default     = "opc"
}

variable "bastion_private_key" {
  description = "The private key path to access the bastion host."
}

variable "vm_user" {
  description = "The SSH user to connect to the master host."
  default     = "opc"
}

