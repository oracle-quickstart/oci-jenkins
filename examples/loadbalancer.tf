############################################
# Create Load Balancer
############################################

resource "oci_load_balancer" "JenkinsLB" {
  shape          = "100Mbps"
  compartment_id = "${var.compartment_ocid}"

  subnet_ids = [
    "${oci_core_subnet.JenkinsLBSubnet1.id}",
    "${oci_core_subnet.JenkinsLBSubnet2.id}",
  ]

  display_name = "JenkinsLB"
}

resource "oci_load_balancer_backend_set" "JenkinsLBBes" {
  name             = "JenkinsLBBes"
  load_balancer_id = "${oci_load_balancer.JenkinsLB.id}"
  policy           = "ROUND_ROBIN"

  health_checker {
    port     = "${var.http_port}"
    protocol = "TCP"
  }
}

resource "oci_load_balancer_listener" "JenkinsLBLsnr" {
  load_balancer_id         = "${oci_load_balancer.JenkinsLB.id}"
  name                     = "http"
  default_backend_set_name = "${oci_load_balancer_backend_set.JenkinsLBBes.name}"
  port                     = 80
  protocol                 = "HTTP"

  connection_configuration {
    idle_timeout_in_seconds = "2"
  }
}

resource "oci_load_balancer_backend" "JenkinsLBBe" {
  load_balancer_id = "${oci_load_balancer.JenkinsLB.id}"
  backendset_name  = "${oci_load_balancer_backend_set.JenkinsLBBes.name}"
  ip_address       = "${module.jenkins.master_private_ip}"
  port             = "${var.http_port}"
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}
