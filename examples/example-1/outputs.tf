output "master_public_ip" {
  value = "${module.jenkins.master_public_ip}"
}

output "slave_private_ips" {
  value = "${module.jenkins.slave_private_ips}"
}

output "master_login_url" {
  value = "${module.jenkins.master_login_url}"
}

output "master_login_init_password" {
  value = "${module.jenkins.master_login_init_password}"
}
