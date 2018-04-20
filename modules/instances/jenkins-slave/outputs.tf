output "ids" {
  value = ["${oci_core_instance.TFJenkinsSlave.*.id}"]
}

output "private_ips" {
  value = ["${oci_core_instance.TFJenkinsSlave.*.private_ip}"]
}

output "public_ips" {
  value = ["${oci_core_instance.TFJenkinsSlave.*.public_ip}"]
}

output "slave_host_names" {
  value = ["${oci_core_instance.TFJenkinsSlave.*.display_name}"]
}
