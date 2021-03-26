output "master_instance_id" {
  value = module.jenkins-master.id
}

output "master_private_ip" {
  value = module.jenkins-master.private_ip
}

output "agent_instance_ids" {
  value = module.jenkins-agent.ids
}

output "agent_private_ips" {
  value = module.jenkins-agent.private_ips
}

output "master_login_url" {
  value = "http://${module.jenkins-master.private_ip}:${var.http_port}"
}
output "agent_host_names" {
  value = module.jenkins-agent.agent_host_names
}
