############################################
# Datasource
############################################
# Gets a list of Availability Domains
data "oci_identity_availability_domains" "ad" {
  compartment_id = "${var.tenancy_ocid}"
}

data "template_file" "ad_names" {
  count    = "${length(data.oci_identity_availability_domains.ad.availability_domains)}"
  template = "${lookup(data.oci_identity_availability_domains.ad.availability_domains[count.index], "name")}"
}


# Gets a list of vNIC attachments on the nat instance
data "oci_core_vnic_attachments" "nat" {
  compartment_id      = "${var.compartment_ocid}"
  availability_domain = "${data.template_file.ad_names.*.rendered[var.nat_ad_index]}"
  instance_id         = "${oci_core_instance.JenkinsNat.id}"
}

# Gets the OCID of the first (default) vNIC on the NAT instance
data "oci_core_vnic" "nat" {
  vnic_id = "${lookup(data.oci_core_vnic_attachments.nat.vnic_attachments[0],"vnic_id")}"
}

data "oci_core_private_ips" "nat" {
  ip_address = "${data.oci_core_vnic.nat.private_ip_address}"
  subnet_id  = "${oci_core_subnet.JenkinsNat.id}"
}
