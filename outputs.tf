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

output "master_login_url" {
  value = "http://${module.jenkins-master.public_ip}:${var.http_port}"
}

output "master_login_init_password" {
  value = "Please check the initial password on master instance: /var/lib/jenkins/secrets/initialAdminPassword"
}
