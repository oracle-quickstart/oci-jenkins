## DATASOURCE
# Init Script Files
data "template_file" "install_slave" {
  template = "${file("${path.module}/scripts/setup.sh")}"

  vars {
    jenkins_master_ip  = "${var.jenkins_master_ip}"
    jenkins_master_url = "${local.jenkins_master_url}"
  }
}

data "template_file" "config_slave" {
  template = "${file("${path.module}/scripts/config.sh")}"

  vars {
    jenkins_master_url = "${local.jenkins_master_url}"
  }
}

locals {
  jenkins_master_url = "http://${var.jenkins_master_ip}:${var.jenkins_master_port}"
}

# Jenkins Slaves
resource "oci_core_instance" "TFJenkinsSlave" {
  count               = "${var.number_of_slaves}"
  availability_domain = "${var.availability_domains[count.index%length(var.availability_domains)]}"

  compartment_id = "${var.compartment_ocid}"
  display_name   = "${var.label_prefix}${var.slave_display_name}-${count.index+1}"
  shape          = "${var.shape}"

  create_vnic_details {
    subnet_id        = "${var.subnet_ids[count.index%length(var.subnet_ids)]}"
    display_name     = "${var.label_prefix}${var.slave_display_name}-${count.index+1}"
    assign_public_ip = true
    hostname_label   = "${var.slave_display_name}-${count.index+1}"
  }

  metadata {
    ssh_authorized_keys = "${file("${var.ssh_authorized_keys}")}"
  }

  source_details {
    source_id   = "${var.image_id}"
    source_type = "image"
  }

  #Prepare files on slave node
  provisioner "file" {
    connection = {
      host        = "${self.public_ip}"
      agent       = false
      timeout     = "5m"
      user        = "opc"
      private_key = "${file("${var.ssh_private_key}")}"
    }

    content     = "${file("${var.ssh_private_key}")}"
    destination = "/tmp/key.pem"
  }

  provisioner "file" {
    connection = {
      host        = "${self.public_ip}"
      agent       = false
      timeout     = "5m"
      user        = "opc"
      private_key = "${file("${var.ssh_private_key}")}"
    }

    content     = "${data.template_file.install_slave.rendered}"
    destination = "/tmp/setup_slave.sh"
  }

  provisioner "file" {
    connection = {
      host        = "${self.public_ip}"
      agent       = false
      timeout     = "5m"
      user        = "opc"
      private_key = "${file("${var.ssh_private_key}")}"
    }

    content     = "${data.template_file.config_slave.rendered}"
    destination = "/tmp/config_slave.sh"
  }

  # Install slave
  provisioner "remote-exec" {
    connection = {
      host        = "${self.public_ip}"
      agent       = false
      timeout     = "5m"
      user        = "opc"
      private_key = "${file("${var.ssh_private_key}")}"
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
      timeout     = "10m"
      user        = "opc"
      private_key = "${file("${var.ssh_private_key}")}"
    }

    inline = [
      "sudo chmod +x /tmp/config_slave.sh",
      "/tmp/config_slave.sh ${self.display_name}",
    ]
  }
}
