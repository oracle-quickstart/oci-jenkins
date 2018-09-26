############################################
# Create VCN
############################################
resource "oci_core_virtual_network" "JenkinsVCN" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "JenkinsVCN"
  cidr_block     = "${lookup(var.network_cidrs, "vcn_cidr")}"
  dns_label      = "JenkinsVCN"
}

############################################
# Create Internet Gateways
############################################
resource "oci_core_internet_gateway" "JenkinsIG" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.JenkinsVCN.id}"
  display_name   = "JenkinsIG"
}

############################################
# Create Route Table
############################################
resource "oci_core_route_table" "public" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.JenkinsVCN.id}"
  display_name   = "public"

  route_rules {
    cidr_block        = "0.0.0.0/0"
    network_entity_id = "${oci_core_internet_gateway.JenkinsIG.id}"
  }
}

resource "oci_core_route_table" "private" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.JenkinsVCN.id}"
  display_name   = "private"

  route_rules {
    cidr_block        = "0.0.0.0/0"
    network_entity_id = "${lookup(data.oci_core_private_ips.nat.private_ips[0],"id")}"
  }
}

############################################
# Create Security List
############################################
resource "oci_core_security_list" "JenkinsPrivate" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "JenkinsPrivate"
  vcn_id         = "${oci_core_virtual_network.JenkinsVCN.id}"

  egress_security_rules = [{
    destination = "0.0.0.0/0"
    protocol    = "6"
  }]

  ingress_security_rules = [{
    tcp_options {
      "max" = 22
      "min" = 22
    }

    protocol = "6"
    source   = "0.0.0.0/0"
  },
    {
      tcp_options {
        "max" = "${var.http_port}"
        "min" = "${var.http_port}"
      }

      protocol = "6"
      source   = "0.0.0.0/0"
    },
    {
      tcp_options {
        "max" = "${var.jnlp_port}"
        "min" = "${var.jnlp_port}"
      }

      protocol = "6"
      source   = "0.0.0.0/0"
    },
    {
      protocol = "6"
      source   = "0.0.0.0/0"

      tcp_options {
        "min" = 443
        "max" = 443
      }
    },
  ]
}

resource "oci_core_security_list" "JenkinsBastion" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "JenkinsBastion"
  vcn_id         = "${oci_core_virtual_network.JenkinsVCN.id}"

  egress_security_rules = [{
   tcp_options {
     "max" = 22
     "min" = 22
   }

   protocol    = "6"
   destination = "${lookup(var.network_cidrs, "vcn_cidr")}"
 }]

  ingress_security_rules = [{
    tcp_options {
      "max" = 22
      "min" = 22
    }

    protocol = "6"
    source   = "0.0.0.0/0"
  }]
}

resource "oci_core_security_list" "JenkinsNat" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "nat"
  vcn_id         = "${oci_core_virtual_network.JenkinsVCN.id}"

  egress_security_rules = [{
    protocol    = "6"
    destination = "0.0.0.0/0"
  }]

  ingress_security_rules = [{
    protocol = "6"
    source   = "${lookup(var.network_cidrs, "vcn_cidr")}"
  }]
}

resource "oci_core_security_list" "JenkinsLB" {
  display_name   = "jenkinslb"
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.JenkinsVCN.id}"

  egress_security_rules = [{
    protocol    = "all"
    destination = "0.0.0.0/0"
  }]

  ingress_security_rules = [
    {
      protocol = "6"
      source   = "0.0.0.0/0"

      tcp_options {
        "min" = 80
        "max" = 80
      }
    },
    {
      protocol = "6"
      source   = "0.0.0.0/0"

      tcp_options {
        "min" = 443
        "max" = 443
      }
    },
  ]
}

############################################
# Create Master Subnet
############################################
resource "oci_core_subnet" "JenkinsMasterSubnetAD" {
  availability_domain = "${data.template_file.ad_names.*.rendered[0]}"
  cidr_block          = "${lookup(var.network_cidrs, "masterSubnetAD")}"
  display_name        = "${var.label_prefix}JenkinsMasterSubnetAD"
  dns_label           = "masterad"
  security_list_ids   = ["${oci_core_security_list.JenkinsPrivate.id}"]
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.JenkinsVCN.id}"
  route_table_id      = "${oci_core_route_table.private.id}"
  dhcp_options_id     = "${oci_core_virtual_network.JenkinsVCN.default_dhcp_options_id}"
}

############################################
# Create Slave Subnet
############################################
resource "oci_core_subnet" "JenkinsSlaveSubnetAD" {
  count               = "${length(data.template_file.ad_names.*.rendered)}"
  availability_domain = "${data.template_file.ad_names.*.rendered[count.index]}"
  cidr_block          = "${lookup(var.network_cidrs, "slaveSubnetAD${count.index+1}")}"
  display_name        = "${var.label_prefix}JenkinsSlaveSubnetAD${count.index+1}"
  dns_label           = "slavead${count.index+1}"
  security_list_ids   = ["${oci_core_security_list.JenkinsPrivate.id}"]
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.JenkinsVCN.id}"
  route_table_id      = "${oci_core_route_table.private.id}"
  dhcp_options_id     = "${oci_core_virtual_network.JenkinsVCN.default_dhcp_options_id}"
}

############################################
# Create Bastion Subnet
############################################
resource "oci_core_subnet" "JenkinsBastion" {
  availability_domain = "${data.template_file.ad_names.*.rendered[var.bastion_ad_index]}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "JenkinsBastionAD${var.bastion_ad_index+1}"
  cidr_block          = "${lookup(var.network_cidrs, "bastionSubnetAD")}"
  security_list_ids   = ["${oci_core_security_list.JenkinsBastion.id}"]
  vcn_id              = "${oci_core_virtual_network.JenkinsVCN.id}"
  route_table_id      = "${oci_core_route_table.public.id}"
  dhcp_options_id     = "${oci_core_virtual_network.JenkinsVCN.default_dhcp_options_id}"
}

############################################
# Create NAT Subnet
############################################
resource "oci_core_subnet" "JenkinsNat" {
  availability_domain = "${data.template_file.ad_names.*.rendered[var.nat_ad_index]}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "JenkinsNatAD${var.nat_ad_index+1}"
  cidr_block          = "${lookup(var.network_cidrs, "natSubnetAD")}"
  security_list_ids   = ["${oci_core_security_list.JenkinsNat.id}"]
  vcn_id              = "${oci_core_virtual_network.JenkinsVCN.id}"
  route_table_id      = "${oci_core_route_table.public.id}"
  dhcp_options_id     = "${oci_core_virtual_network.JenkinsVCN.default_dhcp_options_id}"
}

############################################
# Create LoadBalancer Subnet
############################################
resource "oci_core_subnet" "JenkinsLBSubnet1" {
  availability_domain = "${data.template_file.ad_names.*.rendered[0]}"
  cidr_block          = "${lookup(var.network_cidrs, "lbSubnet1")}"
  display_name        = "JenkinsLBSubnet1"
  dns_label           = "subnet1"
  security_list_ids   = ["${oci_core_security_list.JenkinsLB.id}"]
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.JenkinsVCN.id}"
  route_table_id      = "${oci_core_route_table.public.id}"
  dhcp_options_id     = "${oci_core_virtual_network.JenkinsVCN.default_dhcp_options_id}"
}

resource "oci_core_subnet" "JenkinsLBSubnet2" {
  availability_domain = "${data.template_file.ad_names.*.rendered[1]}"
  cidr_block          = "${lookup(var.network_cidrs, "lbSubnet2")}"
  display_name        = "JenkinsLBSubnet2"
  dns_label           = "subnet2"
  security_list_ids   = ["${oci_core_security_list.JenkinsLB.id}"]
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.JenkinsVCN.id}"
  route_table_id      = "${oci_core_route_table.public.id}"
  dhcp_options_id     = "${oci_core_virtual_network.JenkinsVCN.default_dhcp_options_id}"
}
