output "controller_private_ip" {
  value = module.jenkins.controller_private_ip
}

output "agent_private_ips" {
  value = module.jenkins.agent_private_ips
}

output "lb_public_ip" {
  value = [oci_load_balancer.JenkinsLB.ip_addresses]
}

output "jenkins_login_url" {
  value = "http://${oci_load_balancer.JenkinsLB.ip_addresses[0]}"
}

