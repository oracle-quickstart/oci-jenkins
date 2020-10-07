############################################
# Datasource
############################################
# Gets a list of Availability Domains
data "oci_identity_availability_domains" "ad" {
  compartment_id = var.tenancy_ocid
}

data "template_file" "ad_names" {
  count = length(
    data.oci_identity_availability_domains.ad.availability_domains,
  )
  template = data.oci_identity_availability_domains.ad.availability_domains[count.index]["name"]
}

data "oci_core_vnic_attachments" "bastion_VNIC1_attach" {
  availability_domain = data.template_file.ad_names[var.bastion_ad_index].rendered
  compartment_id      = var.compartment_ocid
  instance_id         = oci_core_instance.JenkinsBastion.id
}

data "oci_core_vnic" "bastion_VNIC1" {
  vnic_id = data.oci_core_vnic_attachments.bastion_VNIC1_attach.vnic_attachments.0.vnic_id
}
