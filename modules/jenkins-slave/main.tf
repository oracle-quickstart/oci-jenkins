# Init Script Files
data "template_file" "config_slave" {
  template = file("${path.module}/scripts/config.sh")

  vars = {
    jenkins_master_url = local.jenkins_master_url
    jenkins_password   = var.jenkins_password
  }
}

locals {
  jenkins_master_url = "http://${var.jenkins_master_ip}:${var.jenkins_master_port}"
}

# Jenkins Slaves
resource "oci_core_instance" "TFJenkinsSlave" {
  count               = var.number_of_slaves
#  availability_domain = var.availability_domains
#  availability_domain = ""
 availability_domain = var.availability_domains[count.index % length(var.availability_domains)]
  compartment_id      = var.compartment_ocid
  display_name        = "${var.label_prefix}${var.slave_display_name}-${count.index + 1}"
  shape               = var.shape
#   shape               = "VM.Standard1.4"
  create_vnic_details {
    subnet_id        = var.subnet_ids[count.index % length(var.subnet_ids)]
    display_name     = "${var.label_prefix}${var.slave_display_name}-${count.index + 1}"
    assign_public_ip = false
    hostname_label   = "${var.slave_display_name}-${count.index + 1}"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_authorized_keys
  }

  source_details {
    source_id   = var.image_id
    source_type = "image"
  }

  provisioner "file" {
    connection {
      host        = self.private_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key

      bastion_host        = var.bastion_host
      bastion_user        = var.bastion_user
      bastion_private_key = var.bastion_private_key
    }

    content     = data.template_file.config_slave.rendered
    destination = "~/config_slave.sh"
  }

  # Register & Launch slave
  # Register & Launch slave
  provisioner "remote-exec" {
    connection {
      host        = self.private_ip
      agent       = false
      timeout     = "10m"
      user        = var.vm_user
      private_key = var.ssh_private_key

      bastion_host        = var.bastion_host
      bastion_user        = var.bastion_user
      bastion_private_key = var.bastion_private_key
    }

    inline = [
      "sudo chmod +x ~/config_slave.sh",
      "sudo ~/config_slave.sh ${self.display_name}",
    ]
  }
}

