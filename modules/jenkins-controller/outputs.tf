## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

output "id" {
  value = oci_core_instance.TFJenkinsController.id
}

output "private_ip" {
  value = oci_core_instance.TFJenkinsController.private_ip
}

output "public_ip" {
  value = oci_core_instance.TFJenkinsController.public_ip
}

