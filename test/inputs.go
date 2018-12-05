package test

type Inputs struct {
	Tenancy_ocid        string `json:"tenancy_ocid"`
	Compartment_ocid    string `json:"compartment_ocid"`
	User_ocid           string `json:"user_ocid"`
	Region              string `json:"region"`
	Fingerprint         string `json:"fingerprint"`
	Private_key_path    string `json:"private_key_path"`
	Ssh_authorized_keys string `json:"ssh_authorized_keys"`
	Ssh_private_key     string `json:"ssh_private_key"`
	Jenkins_password    string `json:"jenkins_password"`
	Bastion_authorized_keys string `json:"bastion_authorized_keys"`
	Bastion_private_key string `json:"bastion_private_key"`
}
