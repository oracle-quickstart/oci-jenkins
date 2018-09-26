## DATASOURCE
# Init Script Files
data "template_file" "setup_jenkins" {
  template = "${file("${path.module}/scripts/setup.sh")}"

  vars {
    jenkins_version = "${var.jenkins_version}"
    http_port       = "${var.http_port}"
    jnlp_port       = "${var.jnlp_port}"
    plugins         = "${join(" ", var.plugins)}"
  }
}

## JENKINS MASTER INSTANCE
resource "oci_core_instance" "TFJenkinsMaster" {
  availability_domain = "${var.availability_domain}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "${var.label_prefix}${var.master_display_name}"
  shape               = "${var.shape}"
  subnet_id           = "${var.subnet_id}"
  hostname_label      = "${var.master_display_name}"

  metadata {
    ssh_authorized_keys = "${file("${var.ssh_authorized_keys}")}"
  }

  source_details {
    source_id   = "${var.image_id}"
    source_type = "image"
  }

  provisioner "file" {
    connection = {
      host        = "${self.private_ip}"
      agent       = false
      timeout     = "5m"
      user        = "opc"
      private_key = "${file("${var.ssh_private_key}")}"

      bastion_host        = "${var.bastion_host}"
      bastion_user        = "${var.bastion_user}"
      bastion_private_key = "${file("${var.bastion_private_key}")}"
    }

    content     = "${data.template_file.setup_jenkins.rendered}"
    destination = "~/setup.sh"
  }

  provisioner "remote-exec" {
    connection = {
      host        = "${self.private_ip}"
      agent       = false
      timeout     = "5m"
      user        = "opc"
      private_key = "${file("${var.ssh_private_key}")}"

      bastion_host        = "${var.bastion_host}"
      bastion_user        = "${var.bastion_user}"
      bastion_private_key = "${file("${var.bastion_private_key}")}"
    }

    inline = [
      "chmod +x ~/setup.sh",
      "sudo ~/setup.sh",
    ]
  }

  timeouts {
    create = "10m"
  }
}
