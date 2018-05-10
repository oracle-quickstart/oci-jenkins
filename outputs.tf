output "master_instance_id" {
  value = "${module.jenkins-master.id}"
}

output "master_public_ip" {
  value = "${module.jenkins-master.public_ip}"
}

output "master_private_ip" {
  value = "${module.jenkins-master.private_ip}"
}

output "slave_instance_ids" {
  value = "${module.jenkins-slave.ids}"
}

output "slave_private_ips" {
  value = "${module.jenkins-slave.private_ips}"
}

output "master_login_info" {
  value = [
    "Jenkins Master URL: http://${module.jenkins-master.public_ip}:${var.http_port}",
    "Admin Initial Password: ${module.jenkins-master.admin_init_password}",
  ]
}
