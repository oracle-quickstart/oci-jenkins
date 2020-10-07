output "master_private_ip" {
  value = module.jenkins.master_private_ip
}

output "slave_private_ips" {
  value = module.jenkins.slave_private_ips
}

output "lb_public_ip" {
  value = [oci_load_balancer.JenkinsLB.ip_addresses]
}

output "jenkins_login_url" {
  value = "http://${oci_load_balancer.JenkinsLB.ip_addresses[0]}"
}

output "SSH_private_key" {
  value = tls_private_key.public_private_key_pair.private_key_pem
}

output "Bastion_Public_IP" {
  value = data.oci_core_vnic.bastion_VNIC1.public_ip_address
}
