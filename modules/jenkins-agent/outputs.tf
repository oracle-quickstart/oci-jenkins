output "ids" {
  value = [oci_core_instance.TFJenkinsAgent.*.id]
}

output "private_ips" {
  value = [oci_core_instance.TFJenkinsAgent.*.private_ip]
}

output "agent_host_names" {
  value = [oci_core_instance.TFJenkinsAgent.*.display_name]
}

