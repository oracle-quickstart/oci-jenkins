output "master_public_ip" {
  value = "${module.jenkins.master_public_ip}"
}

output "slave_private_ips" {
  value = "${module.jenkins.slave_private_ips}"
}

output "master_login_info" {
  value = "${module.jenkins.master_login_info}"
}
