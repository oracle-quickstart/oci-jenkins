############################################
# Create Load Balancer
############################################

module "load_balancer" {
  source         = "git::ssh://git@bitbucket.oci.oraclecorp.com:7999/tfs/terraform-oci-load-balancer.git"
  compartment_id = "${var.compartment_ocid}"
  display_name   = "JenkinsLB"
  shape          = "100Mbps"
  is_private     = "false"
  subnet_ids = [
    "${oci_core_subnet.JenkinsLBSubnet1.id}",
    "${oci_core_subnet.JenkinsLBSubnet2.id}",
  ]
  backendset_name                 = "JenkinsLBBes"
  backendset_policy               = "ROUND_ROBIN"
  hc_protocol                     = "TCP"
  hc_port                         = "${var.http_port}"
  backend_count                   = "1"
  backend_ips                     = ["${module.jenkins.master_private_ip}"]
  backend_ports                   = ["${var.http_port}"]
  listener_certificate_name       = "${var.listener_certificate_name}"
  listener_ca_certificate         = "${var.listener_ca_certificate}"
  listener_private_key            = "${var.listener_private_key}"
  listener_public_certificate     = "${var.listener_public_certificate}"
  listener_protocol               = "${var.listener_protocol}"
  ssl_listener_name               = "${var.ssl_listener_name}"
  ssl_listener_port               = "${var.ssl_listener_port}"
  ssl_verify_peer_certificate     = "${var.ssl_verify_peer_certificate}"
  ssl_verify_depth                = "${var.ssl_verify_depth}"
  ssl_listener_hostnames          = "${var.ssl_listener_hostnames}"
  ssl_listener_path_route_set     = "${var.ssl_listener_path_route_set}"
  non_ssl_listener_name           = "${var.non_ssl_listener_name}"
  non_ssl_listener_port           = "${var.non_ssl_listener_port}"
  non_ssl_listener_hostnames      = "${var.non_ssl_listener_hostnames}"
  non_ssl_listener_path_route_set = "${var.non_ssl_listener_path_route_set}"
}
