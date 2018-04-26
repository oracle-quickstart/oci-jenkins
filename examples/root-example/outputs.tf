output "master_instance_ids" {
  value = "${module.jenkins.master_instance_ids}"
}

output "master_public_ips" {
  value = "${module.jenkins.master_public_ips}"
}

output "master_private_ips" {
  value = "${module.jenkins.master_private_ips}"
}

output "slave_instance_ids" {
  value = "${module.jenkins.slave_instance_ids}"
}

output "slave_private_ips" {
  value = "${module.jenkins.slave_private_ips}"
}
