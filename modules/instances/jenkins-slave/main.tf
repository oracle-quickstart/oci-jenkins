## DATASOURCE

# Prevent oci_core_images image list from changing underneath us.
data "oci_core_images" "ImageOCID" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "${var.oracle_linux_image_name}"
}

# Cloud call to get a list of Availability Domains
data "oci_identity_availability_domains" "ADs" {
  compartment_id = "${var.tenancy_ocid}"
}

# Init Script Files
data "template_file" "install_slave" {
  template = "${file("./modules/instances/jenkins-slave/scripts/setup.sh")}"

  vars {
    jenkins_master_url = "${local.jenkins_master_url}"
    jenkins_master_ip  = "${var.jenkins_master_ip}"
  }
}

data "template_file" "config_slave" {
  template = "${file("./modules/instances/jenkins-slave/scripts/config.sh")}"

  vars {
    jenkins_master_url = "${local.jenkins_master_url}"
    jenkins_master_ip  = "${var.jenkins_master_ip}"
  }
}

locals {
  jenkins_master_url = "http://${var.jenkins_master_ip}:${var.jenkins_master_port}"
}

# Jenkins Slaves
resource "oci_core_instance" "TFJenkinsSlave" {
  count               = "${var.count}"
  availability_domain = "${var.availability_domain}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "${var.label_prefix}${var.display_name_prefix}-${count.index}"
  hostname_label      = "${var.hostname_label_prefix}-${count.index}"
  image               = "${lookup(data.oci_core_images.ImageOCID.images[0], "id")}"
  shape               = "${var.shape}"
  subnet_id           = "${var.subnet_id}"

  create_vnic_details {
    subnet_id        = "${var.subnet_id}"
    display_name     = "${var.label_prefix}${var.display_name_prefix}-${count.index}"
    assign_public_ip = true
    hostname_label   = "${var.hostname_label_prefix}-${count.index}"
  }

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
  }

  #Prepare files on slave node
  provisioner "file" {
    connection = {
      host        = "${self.public_ip}"
      agent       = false
      timeout     = "3m"
      user        = "opc"
      private_key = "${var.ssh_private_key}"
    }

    content     = "${var.ssh_private_key}"
    destination = "/tmp/key.pem"
  }

  provisioner "file" {
    connection = {
      host        = "${self.public_ip}"
      agent       = false
      timeout     = "3m"
      user        = "opc"
      private_key = "${var.ssh_private_key}"
    }

    content     = "${data.template_file.install_slave.rendered}"
    destination = "/tmp/setup_slave.sh"
  }

  provisioner "file" {
    connection = {
      host        = "${self.public_ip}"
      agent       = false
      timeout     = "30m"
      user        = "opc"
      private_key = "${var.ssh_private_key}"
    }

    content     = "${data.template_file.config_slave.rendered}"
    destination = "/tmp/config_slave.sh"
  }

  # Install slave
  provisioner "remote-exec" {
    connection = {
      host        = "${self.public_ip}"
      agent       = false
      timeout     = "3m"
      user        = "opc"
      private_key = "${var.ssh_private_key}"
    }

    inline = [
      "chmod +x /tmp/setup_slave.sh",
      "sudo /tmp/setup_slave.sh",
    ]
  }

  # Register & Launch slave
  provisioner "remote-exec" {
    connection = {
      host        = "${self.public_ip}"
      agent       = false
      timeout     = "30m"
      user        = "opc"
      private_key = "${var.ssh_private_key}"
    }

    inline = [
      "sudo chmod +x /tmp/config_slave.sh",
      "/tmp/config_slave.sh ${self.display_name}",
    ]
  }
}
