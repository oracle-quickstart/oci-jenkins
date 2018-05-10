############################################
# Create VCN
############################################
resource "oci_core_virtual_network" "JenkinsVCN" {
  cidr_block     = "${lookup(var.network_cidrs, "VCN-CIDR")}"
  compartment_id = "${var.compartment_ocid}"
  display_name   = "JenkinsVCN"
  dns_label      = "ocijenkins"
}

############################################
# Create Internet Gateways
############################################
resource "oci_core_internet_gateway" "JenkinsIG" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "${var.label_prefix}JenkinsIG"
  vcn_id         = "${oci_core_virtual_network.JenkinsVCN.id}"
}

############################################
# Create Route Table
############################################
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

############################################
# Create Security List
############################################
resource "oci_core_security_list" "JenkinsMasterSubnet" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "${var.label_prefix}JenkinsSecurityList"
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

############################################
# Create Master Subnet
############################################
resource "oci_core_subnet" "JenkinsMasterSubnetAD" {
  availability_domain = "${data.template_file.ad_names.*.rendered[0]}"
  cidr_block          = "${lookup(var.network_cidrs, "masterSubnetAD")}"
  display_name        = "${var.label_prefix}JenkinsMasterSubnetAD"
  dns_label           = "masterad"
  security_list_ids   = ["${oci_core_security_list.JenkinsMasterSubnet.id}"]
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.JenkinsVCN.id}"
  route_table_id      = "${oci_core_route_table.JenkinsRT.id}"
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
  security_list_ids   = ["${oci_core_virtual_network.JenkinsVCN.default_security_list_id}"]
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.JenkinsVCN.id}"
  route_table_id      = "${oci_core_route_table.JenkinsRT.id}"
  dhcp_options_id     = "${oci_core_virtual_network.JenkinsVCN.default_dhcp_options_id}"
}
