## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# ------------------------------------------------------------------------------
# Setup Bastion Host
# ------------------------------------------------------------------------------

locals {
  bastion_shape             = var.bastion_shape
  bastion_flex_shape_ocpus  = var.bastion_flex_shape_ocpus
  bastion_flex_shape_memory = var.bastion_flex_shape_memory
  bastion_is_flex_shape     = length(regexall("Flex", local.bastion_shape)) > 0 ? [1] : []
}

resource "oci_core_instance" "JenkinsBastion" {
  availability_domain = data.template_file.ad_names[var.bastion_ad_index].rendered
  compartment_id      = var.compartment_ocid
  display_name        = var.bastion_display_name
  shape               = var.bastion_shape

  create_vnic_details {
    subnet_id        = oci_core_subnet.JenkinsBastion.id
    assign_public_ip = true
  }

  dynamic "shape_config" {
    for_each = local.bastion_is_flex_shape
    content {
      ocpus         = local.bastion_flex_shape_ocpus
      memory_in_gbs = local.bastion_flex_shape_memory
    }
  }

  metadata = {
    ssh_authorized_keys = file(var.bastion_authorized_keys)
  }

  source_details {
    source_id   = lookup(data.oci_core_images.bastion_image.images[0], "id")
    source_type = "image"
  }
}

# ------------------------------------------------------------------------------
# DEPLOY THE JENKINS CLUSTER
# ------------------------------------------------------------------------------
module "jenkins" {
  source                       = "github.com/oracle-quickstart/oci-jenkins"
  compartment_ocid             = var.compartment_ocid
  jenkins_version              = var.jenkins_version
  jenkins_password             = var.jenkins_password
  controller_ad                = data.template_file.ad_names[0].rendered
  controller_subnet_id         = oci_core_subnet.JenkinsControllerSubnetAD.id
  controller_image_id          = lookup(data.oci_core_images.controller_image.images[0], "id")
  controller_shape             = var.controller_shape
  controller_flex_shape_ocpus  = var.controller_flex_shape_ocpus
  controller_flex_shape_memory = var.controller_flex_shape_memory
  plugins                      = var.plugins
  agent_count                  = var.agent_count
  agent_ads                    = data.template_file.ad_names.*.rendered
  agent_subnet_ids             = split(",", join(",", oci_core_subnet.JenkinsAgentSubnetAD.*.id))
  agent_image_id               = lookup(data.oci_core_images.agent_image.images[0], "id")
  agent_shape                  = var.agent_shape
  agent_flex_shape_ocpus       = var.agent_flex_shape_ocpus
  agent_flex_shape_memory      = var.agent_flex_shape_memory
  ssh_authorized_keys          = file(var.ssh_authorized_keys)
  ssh_private_key              = file(var.ssh_private_key)
  bastion_host                 = oci_core_instance.JenkinsBastion.public_ip
  bastion_user                 = var.bastion_user
  bastion_private_key          = file(var.bastion_private_key)
  bastion_authorized_keys      = file(var.bastion_authorized_keys)
}

