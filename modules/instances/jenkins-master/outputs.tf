output "ids" {
  value = ["${oci_core_instance.TFJenkinsMaster.*.id}"]
}

output "private_ips" {
  value = ["${oci_core_instance.TFJenkinsMaster.*.private_ip}"]
}

output "public_ips" {
  value = ["${oci_core_instance.TFJenkinsMaster.*.public_ip}"]
}
