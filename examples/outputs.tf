output "master_private_ip" {
  value = "${module.jenkins.master_private_ip}"
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

output "lb_public_ip" {
  value = ["${oci_load_balancer.JenkinsLB.ip_addresses}"]
}

output "jenkins_login_url" {
  value = "http://${oci_load_balancer.JenkinsLB.ip_addresses[0]}"
}
