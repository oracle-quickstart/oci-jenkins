output "master_private_ip" {
  value = "${module.jenkins.master_private_ip}"
}

output "slave_private_ips" {
  value = "${module.jenkins.slave_private_ips}"
}

output "lb_public_ip" {
  value = ["${module.load_balancer.ip_addresses}"]
}

output "jenkins_login_url" {
  value = "http://${module.load_balancer.ip_addresses[0]}"
}
