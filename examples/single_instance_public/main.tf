## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "tls_private_key" "public_private_key_pair" {
  algorithm = "RSA"
}

module "jenkins" {
  source                       = "github.com/oracle-quickstart/oci-jenkins"
  compartment_ocid             = var.compartment_ocid
  jenkins_version              = var.jenkins_version
  jenkins_password             = var.jenkins_password
  controller_ad                = data.template_file.ad_names[0].rendered
  controller_subnet_id         = oci_core_subnet.JenkinsSubnet.id
  controller_image_id          = lookup(data.oci_core_images.controller_image.images[0], "id")
  controller_shape             = var.controller_shape
  controller_flex_shape_ocpus  = var.controller_flex_shape_ocpus
  controller_flex_shape_memory = var.controller_flex_shape_memory
  controller_assign_public_ip  = true
  plugins                      = var.plugins
  agent_count                  = 0
  ssh_authorized_keys          = tls_private_key.public_private_key_pair.public_key_openssh
  ssh_private_key              = tls_private_key.public_private_key_pair.private_key_pem
}

