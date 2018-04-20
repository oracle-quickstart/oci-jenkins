## Gets a list of availability domains
data "oci_identity_availability_domains" "ADs" {
  compartment_id = "${var.tenancy_ocid}"
}

## Create VCN
resource "oci_core_virtual_network" "JenkinsVCN" {
  cidr_block     = "${lookup(var.network_cidrs, "VCN-CIDR")}"
  compartment_id = "${var.compartment_ocid}"
  display_name   = "${var.label_prefix}${var.vcn_dns_name}"
  dns_label      = "${var.vcn_dns_name}"
}

## Create Internet Gateways
resource "oci_core_internet_gateway" "JenkinsIG" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "${var.label_prefix}JenkinsIG"
  vcn_id         = "${oci_core_virtual_network.JenkinsVCN.id}"
}

## Create Route Table
resource "oci_core_route_table" "JenkinsRT" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.JenkinsVCN.id}"
  display_name   = "${var.label_prefix}JenkinsRouteTable"

  route_rules {
    cidr_block = "0.0.0.0/0"

    # Internet Gateway route target for instances on public subnets
    network_entity_id = "${oci_core_internet_gateway.JenkinsIG.id}"
  }
}

## Create Security List For Jenkins Master Subnet
resource "oci_core_security_list" "JenkinsMasterSubnet" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "${var.label_prefix}JenkinsMasterSecurityList"
  vcn_id         = "${oci_core_virtual_network.JenkinsVCN.id}"

  egress_security_rules = [{
    destination = "0.0.0.0/0"
    protocol    = "all"
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
  ]
}

## Create Jenkins Master Subnet On AD1
resource "oci_core_subnet" "JenkinsMasterSubnetAD1" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0],"name")}"
  cidr_block          = "${lookup(var.network_cidrs, "masterSubnetAD1")}"
  display_name        = "${var.label_prefix}JenkinsMasterSubnetAD1"
  dns_label           = "jenmasterad1"
  security_list_ids   = ["${oci_core_security_list.JenkinsMasterSubnet.id}"]
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.JenkinsVCN.id}"
  route_table_id      = "${oci_core_route_table.JenkinsRT.id}"
  dhcp_options_id     = "${oci_core_virtual_network.JenkinsVCN.default_dhcp_options_id}"
}

## Create Jenkins Slave Subnet On AD1
resource "oci_core_subnet" "JenkinsSlaveSubnetAD1" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0],"name")}"
  cidr_block          = "${lookup(var.network_cidrs, "slaveSubnetAD1")}"
  display_name        = "${var.label_prefix}JenkinsSlaveSubnetAD1"
  dns_label           = "jenslavead1"
  security_list_ids   = ["${oci_core_virtual_network.JenkinsVCN.default_security_list_id}"]
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.JenkinsVCN.id}"
  route_table_id      = "${oci_core_route_table.JenkinsRT.id}"
  dhcp_options_id     = "${oci_core_virtual_network.JenkinsVCN.default_dhcp_options_id}"
}
