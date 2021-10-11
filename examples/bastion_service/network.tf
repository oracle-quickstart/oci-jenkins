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
# Create NAT Gateway
############################################
resource "oci_core_nat_gateway" "JenkinsNG" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.JenkinsVCN.id
  display_name   = "JenkinsNG"
}

############################################
# Create Route Table
############################################
resource "oci_core_route_table" "public" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.JenkinsVCN.id
  display_name   = "public"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.JenkinsIG.id
  }
}

resource "oci_core_route_table" "private" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.JenkinsVCN.id
  display_name   = "private"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.JenkinsNG.id
  }
}

############################################
# Create Security List
############################################
resource "oci_core_security_list" "JenkinsPrivate" {
  compartment_id = var.compartment_ocid
  display_name   = "JenkinsPrivate"
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

resource "oci_core_security_list" "JenkinsBastion" {
  compartment_id = var.compartment_ocid
  display_name   = "JenkinsBastion"
  vcn_id         = oci_core_virtual_network.JenkinsVCN.id

  egress_security_rules {
    tcp_options {
      max = 22
      min = 22
    }

    protocol    = "6"
    destination = var.vcn_cidr
  }

  ingress_security_rules {
    tcp_options {
      max = 22
      min = 22
    }

    protocol = "6"
    source   = "0.0.0.0/0"
  }
}

resource "oci_core_security_list" "JenkinsNat" {
  compartment_id = var.compartment_ocid
  display_name   = "JenkinsNat"
  vcn_id         = oci_core_virtual_network.JenkinsVCN.id

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.vcn_cidr
  }
}

resource "oci_core_security_list" "JenkinsLB" {
  display_name   = "JenkinsLB"
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.JenkinsVCN.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      min = 80
      max = 80
    }
  }
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      min = 443
      max = 443
    }
  }
}

############################################
# Create controller Subnet
############################################
resource "oci_core_subnet" "JenkinsControllerSubnetAD" {
  #  availability_domain = data.template_file.ad_names[0].rendered
  cidr_block = cidrsubnet(local.controller_subnet_prefix, 4, 0)
  #  display_name        = "${var.label_prefix}JenkinsControllerSubnetAD"
  display_name      = "JenkinscontrollerSubnet"
  dns_label         = "controllerad"
  security_list_ids = [oci_core_security_list.JenkinsPrivate.id]
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_virtual_network.JenkinsVCN.id
  route_table_id    = oci_core_route_table.private.id
  dhcp_options_id   = oci_core_virtual_network.JenkinsVCN.default_dhcp_options_id
}

############################################
# Create agent Subnet
############################################
resource "oci_core_subnet" "JenkinsAgentSubnetAD" {
  count = length(data.template_file.ad_names.*.rendered)
  #  availability_domain = data.template_file.ad_names[count.index].rendered
  cidr_block        = cidrsubnet(local.agent_subnet_prefix, 4, count.index)
  display_name      = "${var.label_prefix}JenkinsAgentSubnet${count.index + 1}"
  dns_label         = "agentad${count.index + 1}"
  security_list_ids = [oci_core_security_list.JenkinsPrivate.id]
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_virtual_network.JenkinsVCN.id
  route_table_id    = oci_core_route_table.private.id
  dhcp_options_id   = oci_core_virtual_network.JenkinsVCN.default_dhcp_options_id
}

############################################
# Create Bastion Subnet
############################################
resource "oci_core_subnet" "JenkinsBastion" {
  #  availability_domain = data.template_file.ad_names[var.bastion_ad_index].rendered
  compartment_id    = var.compartment_ocid
  display_name      = "JenkinsBastion"
  cidr_block        = cidrsubnet(local.bastion_subnet_prefix, 4, 0)
  security_list_ids = [oci_core_security_list.JenkinsBastion.id]
  vcn_id            = oci_core_virtual_network.JenkinsVCN.id
  route_table_id    = oci_core_route_table.public.id
  dhcp_options_id   = oci_core_virtual_network.JenkinsVCN.default_dhcp_options_id
}

############################################
# Create LoadBalancer Subnet
############################################
resource "oci_core_subnet" "JenkinsLBSubnet1" {
  #  availability_domain = data.template_file.ad_names[0].rendered
  cidr_block        = cidrsubnet(local.lb_subnet_prefix, 4, 0)
  display_name      = "JenkinsLBSubnet1"
  dns_label         = "subnet1"
  security_list_ids = [oci_core_security_list.JenkinsLB.id]
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_virtual_network.JenkinsVCN.id
  route_table_id    = oci_core_route_table.public.id
  dhcp_options_id   = oci_core_virtual_network.JenkinsVCN.default_dhcp_options_id
}

#resource "oci_core_subnet" "JenkinsLBSubnet2" {
#  availability_domain = data.template_file.ad_names[1].rendered
#  cidr_block          = cidrsubnet(local.lb_subnet_prefix, 4, 1)
#  display_name        = "JenkinsLBSubnet2"
#  dns_label           = "subnet2"
#  security_list_ids   = [oci_core_security_list.JenkinsLB.id]
#  compartment_id      = var.compartment_ocid
#  vcn_id              = oci_core_virtual_network.JenkinsVCN.id
#  route_table_id      = oci_core_route_table.public.id
#  dhcp_options_id     = oci_core_virtual_network.JenkinsVCN.default_dhcp_options_id
#}

