output "master_instance_ids" {
  value = "${module.jenkins-master.ids}"
}

output "master_public_ips" {
  value = "${module.jenkins-master.public_ips}"
}

output "master_private_ips" {
  value = "${module.jenkins-master.private_ips}"
}

output "slave_instance_ids" {
  value = "${module.jenkins-slave.ids}"
}

output "slave_private_ips" {
  value = "${module.jenkins-slave.private_ips}"
}
