variable "compartment_ocid" {
  description = "Compartment's OCID where VCN will be created. "
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

variable "controller_ad" {
  description = "The Availability Domain for Jenkins Controller. "
  default     = ""
}

variable "controller_subnet_id" {
  description = "The OCID of the Controller subnet to create the VNIC in. "
  default     = ""
}

variable "jenkins_password" {
  description = "Required field for Jenkins initial password. "
}

variable "jenkins_version" {
  description = "The verion of Jenkins server. "
}

variable "controller_display_name" {
  description = "The name of the Controller instance. "
  default     = "JenkinsController"
}

variable "controller_image_id" {
  description = "The OCID of an image for a Controller instance to use. "
  default     = ""
}

variable "controller_shape" {
  description = "Instance shape to use for Controller instance. "
  default     = "VM.Standard2.1"
}

variable "controller_flex_shape_ocpus" {
  description = "Number of Flex shape OCPUs"
  default     = ""
}

variable "controller_flex_shape_memory" {
  description = "Amount of Flex shape Memory in GB"
  default     = ""
}


variable "controller_user_data" {
  description = "Provide your own base64-encoded data to be used by Cloud-Init to run custom scripts or provide custom Cloud-Init configuration for Controller instance. "
  default     = ""
}

variable "agent_count" {
  description = "Number of agent instances to launch. "
  default     = 1
}

variable "agent_ads" {
  description = "The Availability Domain(s) for Jenkins agent(s). "
  default     = []
}

variable "agent_subnet_ids" {
  description = "List of Jenkins agent subnets' id. "
  default     = []
}

variable "agent_display_name" {
  description = "The name of the agent instance. "
  default     = "JenkinsAgent"
}

variable "agent_image_id" {
  description = "The OCID of an image for agent instance to use.  "
  default     = ""
}

variable "agent_shape" {
  description = "Instance shape to use for agent instance. "
  default     = "VM.Standard2.1"
}

variable "agent_flex_shape_ocpus" {
  description = "Number of Flex shape OCPUs"
  default     = ""
}

variable "agent_flex_shape_memory" {
  description = "Amount of Flex shape Memory in GB"
  default     = ""
}


variable "agent_user_data" {
  description = "Provide your own base64-encoded data to be used by Cloud-Init to run custom scripts or provide custom Cloud-Init configuration for agent instance. "
  default     = ""
}

variable "http_port" {
  description = "The port to use for HTTP traffic to Jenkins. "
  default     = 8080
}

variable "jnlp_port" {
  description = "The Port to use for Jenkins Controller to agent communication bewtween instances. "
  default     = 49187
}

variable "plugins" {
  type        = list(any)
  description = "A list of Jenkins plugins to install, use short names. "
  default     = ["git", "ssh-agents", "oracle-cloud-infrastructure-compute"]
}

variable "use_bastion_service" {
  description = "Use bastion service instead of bastion host"
  default     = false
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
