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

resource "oci_load_balancer_certificate" "JenkinsLBCert" {
  load_balancer_id   = "${oci_load_balancer.JenkinsLB.id}"
  ca_certificate     = "${var.listener_ca_certificate == "" ? "${file("${path.module}/../../examples/quick_start/certs/example.crt.pem")}" : var.listener_ca_certificate}"
  certificate_name   = "JenkinsCets"
  private_key        = "${var.listener_private_key == "" ? "${file("${path.module}/../../examples/quick_start/certs/example.key.pem")}" : var.listener_private_key}"
  public_certificate = "${var.listener_public_certificate == "" ? "${file("${path.module}/../../examples/quick_start/certs/example.crt.pem")}" : var.listener_public_certificate}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "oci_load_balancer_listener" "JenkinsLBLsnr_SSL" {
  load_balancer_id         = "${oci_load_balancer.JenkinsLB.id}"
  name                     = "https"
  default_backend_set_name = "${oci_load_balancer_backend_set.JenkinsLBBes.name}"
  port                     = 443
  protocol                 = "HTTP"

  ssl_configuration {
    certificate_name        = "${oci_load_balancer_certificate.JenkinsLBCert.certificate_name}"
    verify_peer_certificate = false
  }
}


