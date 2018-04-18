output "id" {
  value = "${oci_core_virtual_network.JenkinsVCN.id}"
}

output "jenkinsmaster_subnet_ad1_id" {
  value = "${oci_core_subnet.JenkinsMasterSubnetAD1.id}"
}
