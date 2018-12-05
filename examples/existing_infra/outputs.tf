output "master_private_ip" {
  value = "${module.jenkins.master_private_ip}"
}

output "slave_private_ips" {
  value = "${module.jenkins.slave_private_ips}"
}
