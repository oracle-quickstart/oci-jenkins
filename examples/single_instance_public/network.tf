## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

############################################
# Create VCN
############################################
resource "oci_core_virtual_network" "JenkinsVCN" {
  compartment_id = var.compartment_ocid
  display_name   = "JenkinsVCN"
  cidr_block     = var.vcn_cidr
  dns_label      = "JenkinsVCN"
}

############################################
# Create Internet Gateway
############################################
resource "oci_core_internet_gateway" "JenkinsIG" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.JenkinsVCN.id
  display_name   = "JenkinsIG"
}

############################################
# Create Route Table
############################################
resource "oci_core_route_table" "JenkinsRT" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.JenkinsVCN.id
  display_name   = "JenkinsRT"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.JenkinsIG.id
  }
}

############################################
# Create Security List
############################################
resource "oci_core_security_list" "JenkinsSecList" {
  compartment_id = var.compartment_ocid
  display_name   = "JenkinsSecList"
  vcn_id         = oci_core_virtual_network.JenkinsVCN.id

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "6"
  }

  ingress_security_rules {
    tcp_options {
      max = 22
      min = 22
    }

    protocol = "6"
    source   = "0.0.0.0/0"
  }
  ingress_security_rules {
    tcp_options {
      max = var.http_port
      min = var.http_port
    }

    protocol = "6"
    source   = "0.0.0.0/0"
  }
  ingress_security_rules {
    tcp_options {
      max = var.jnlp_port
      min = var.jnlp_port
    }

    protocol = "6"
    source   = "0.0.0.0/0"
  }
}

############################################
# Create Subnet
############################################
resource "oci_core_subnet" "JenkinsSubnet" {
  cidr_block        = var.subnet_cidr
  display_name      = "JenkinsSubnet"
  dns_label         = "pubsub"
  security_list_ids = [oci_core_security_list.JenkinsSecList.id]
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_virtual_network.JenkinsVCN.id
  route_table_id    = oci_core_route_table.JenkinsRT.id
  dhcp_options_id   = oci_core_virtual_network.JenkinsVCN.default_dhcp_options_id
}

