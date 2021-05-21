## DATASOURCE
# Init Script Files
data "template_file" "setup_jenkins" {
  template = file("${path.module}/scripts/setup.sh")

  vars = {
    jenkins_version  = var.jenkins_version
    jenkins_password = var.jenkins_password
    http_port        = var.http_port
    jnlp_port        = var.jnlp_port
    plugins          = join(" ", var.plugins)
  }
}

data "template_file" "init_jenkins" {
  template = file("${path.module}/scripts/default-user.groovy")

  vars = {
    jenkins_password = var.jenkins_password
  }
}

data "template_file" "disable_controller_executor" {
  template = file("${path.module}/scripts/disable-controller-executor.groovy")
}

## JENKINS Controller INSTANCE
resource "oci_core_instance" "TFJenkinsController" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_ocid
  display_name        = "${var.label_prefix}${var.controller_display_name}"
  shape               = local.shape

  dynamic "shape_config" {
    for_each = local.is_flex_shape
    content {
      ocpus         = local.flex_shape_ocpus
      memory_in_gbs = local.flex_shape_memory
    }
  }


  create_vnic_details {
    subnet_id        = var.subnet_id
    display_name     = "${var.label_prefix}${var.controller_display_name}"
    assign_public_ip = var.assign_public_ip
    hostname_label   = var.controller_display_name
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

    content     = data.template_file.setup_jenkins.rendered
    destination = "~/setup.sh"
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

    content     = data.template_file.init_jenkins.rendered
    destination = "~/default-user.groovy"
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

    content     = data.template_file.disable_controller_executor.rendered
    destination = "~/disable-controller-executor.groovy"
  }  

  provisioner "remote-exec" {
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

    inline = [
      "sleep 60",
      "chmod +x ~/setup.sh",
      "sudo ~/setup.sh",
    ]
  }

  timeouts {
    create = "10m"
  }
}

