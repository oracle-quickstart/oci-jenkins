## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

output "ids" {
  value = [oci_core_instance.TFJenkinsAgent.*.id]
}

output "private_ips" {
  value = [oci_core_instance.TFJenkinsAgent.*.private_ip]
}

output "agent_host_names" {
  value = [oci_core_instance.TFJenkinsAgent.*.display_name]
}

