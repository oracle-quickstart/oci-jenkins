output "master_instance_ids" {
  value = "${module.jenkins-master-ad1.ids}"
}

output "vcn_id" {
  value = "${module.vcn.id}"
}

output "master_subnet_ids" {
  value = "${module.vcn.jenkinsmaster_subnet_ad1_id}"
}

output "master_public_ips" {
  value = "${module.jenkins-master-ad1.public_ips}"
}

output "master_private_ips" {
  value = "${module.jenkins-master-ad1.private_ips}"
}
