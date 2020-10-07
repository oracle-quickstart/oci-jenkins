############################################
# Create Load Balancer
############################################

resource "oci_load_balancer" "JenkinsLB" {
  shape          = "100Mbps"
  compartment_id = var.compartment_ocid

  subnet_ids = [
    oci_core_subnet.JenkinsLBSubnet1.id,
  ]

  display_name = "JenkinsLB"
}

resource "oci_load_balancer_backend_set" "JenkinsLBBes" {
  name             = "JenkinsLBBes"
  load_balancer_id = oci_load_balancer.JenkinsLB.id
  policy           = "ROUND_ROBIN"

  health_checker {
    port     = var.http_port
    protocol = "TCP"
  }
}

resource "oci_load_balancer_listener" "JenkinsLBLsnr" {
  load_balancer_id         = oci_load_balancer.JenkinsLB.id
  name                     = "http"
  default_backend_set_name = oci_load_balancer_backend_set.JenkinsLBBes.name
  port                     = var.lb_http_port
  protocol                 = "HTTP"

  connection_configuration {
    idle_timeout_in_seconds = "2"
  }
}

resource "oci_load_balancer_backend" "JenkinsLBBe" {
  load_balancer_id = oci_load_balancer.JenkinsLB.id
  backendset_name  = oci_load_balancer_backend_set.JenkinsLBBes.name
  ip_address       = module.jenkins.master_private_ip
  port             = var.http_port
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

resource "tls_private_key" "JenkinTLS" {
  count     = var.listener_ca_certificate == "" ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "JenkinsCert" {
  count           = var.listener_ca_certificate == "" ? 1 : 0
  key_algorithm   = tls_private_key.JenkinTLS[0].algorithm
  private_key_pem = tls_private_key.JenkinTLS[0].private_key_pem

  validity_period_hours = 26280
  early_renewal_hours   = 8760
  is_ca_certificate     = true
  allowed_uses          = ["cert_signing"]

  subject {
    common_name  = "*.example.com"
    organization = "Example, Inc"
  }
}

resource "oci_load_balancer_certificate" "JenkinsLBCert" {
  load_balancer_id   = oci_load_balancer.JenkinsLB.id
  ca_certificate     = var.listener_ca_certificate == "" ? tls_self_signed_cert.JenkinsCert[0].cert_pem : var.listener_ca_certificate
  certificate_name   = "JenkinsCert"
  private_key        = var.listener_private_key == "" ? tls_private_key.JenkinTLS[0].private_key_pem : var.listener_private_key
  public_certificate = var.listener_public_certificate == "" ? tls_self_signed_cert.JenkinsCert[0].cert_pem : var.listener_public_certificate

  lifecycle {
    create_before_destroy = true
  }
}

resource "oci_load_balancer_listener" "JenkinsLBLsnr_SSL" {
  load_balancer_id         = oci_load_balancer.JenkinsLB.id
  name                     = "https"
  default_backend_set_name = oci_load_balancer_backend_set.JenkinsLBBes.name
  port                     = 443
  protocol                 = "HTTP"

  ssl_configuration {
    certificate_name        = oci_load_balancer_certificate.JenkinsLBCert.certificate_name
    verify_peer_certificate = false
  }
}

