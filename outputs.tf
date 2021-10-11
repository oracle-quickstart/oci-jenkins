## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

output "controller_instance_id" {
  value = module.jenkins-controller.id
}

output "controller_private_ip" {
  value = module.jenkins-controller.private_ip
}

output "controller_public_ip" {
  value = module.jenkins-controller.public_ip
}

output "agent_instance_ids" {
  value = module.jenkins-agent.ids
}

output "agent_private_ips" {
  value = module.jenkins-agent.private_ips
}

output "controller_login_url" {
  value = "http://${module.jenkins-controller.public_ip}:${var.http_port}"
}

output "agent_host_names" {
  value = module.jenkins-agent.agent_host_names
}
