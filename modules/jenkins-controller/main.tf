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

  dynamic "agent_config" {
    for_each = var.use_bastion_service ? [1] : []
    content {
      are_all_plugins_disabled = false
      is_management_disabled   = false
      is_monitoring_disabled   = false
      plugins_config {
        desired_state = "ENABLED"
        name          = "Bastion"
      }
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

  provisioner "local-exec" {
    command = "sleep 240"
  }
}

resource "oci_bastion_session" "ssh_via_bastion_service" {
  count      = var.use_bastion_service ? 1 : 0
  bastion_id = var.bastion_service_id

  key_details {
    public_key_content = var.bastion_authorized_keys
  }

  target_resource_details {
    session_type                               = "MANAGED_SSH"
    target_resource_id                         = oci_core_instance.TFJenkinsController.id
    target_resource_operating_system_user_name = "opc"
    target_resource_port                       = 22
    target_resource_private_ip_address         = oci_core_instance.TFJenkinsController.private_ip
  }

  display_name           = "ssh_via_bastion_service"
  key_type               = "PUB"
  session_ttl_in_seconds = 1800
}


resource "null_resource" "TFJenkinsControllerConfig" {
  depends_on = [oci_core_instance.TFJenkinsController]

  provisioner "file" {
    connection {
      host        = oci_core_instance.TFJenkinsController.private_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key

      bastion_host        = var.use_bastion_service ? "host.bastion.${var.bastion_service_region}.oci.oraclecloud.com" : var.bastion_host
      bastion_user        = var.use_bastion_service ? oci_bastion_session.ssh_via_bastion_service[0].id : var.bastion_user
      bastion_private_key = var.bastion_private_key
    }

    content     = data.template_file.setup_jenkins.rendered
    destination = "~/setup.sh"
  }

  provisioner "file" {
    connection {
      host        = oci_core_instance.TFJenkinsController.private_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key

      bastion_host        = var.use_bastion_service ? "host.bastion.${var.bastion_service_region}.oci.oraclecloud.com" : var.bastion_host
      bastion_user        = var.use_bastion_service ? oci_bastion_session.ssh_via_bastion_service[0].id : var.bastion_user
      bastion_private_key = var.bastion_private_key
    }

    content     = data.template_file.init_jenkins.rendered
    destination = "~/default-user.groovy"
  }

  provisioner "file" {
    connection {
      host        = oci_core_instance.TFJenkinsController.private_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key

      bastion_host        = var.use_bastion_service ? "host.bastion.${var.bastion_service_region}.oci.oraclecloud.com" : var.bastion_host
      bastion_user        = var.use_bastion_service ? oci_bastion_session.ssh_via_bastion_service[0].id : var.bastion_user
      bastion_private_key = var.bastion_private_key
    }

    content     = data.template_file.disable_controller_executor.rendered
    destination = "~/disable-controller-executor.groovy"
  }

  provisioner "remote-exec" {
    connection {
      host        = oci_core_instance.TFJenkinsController.private_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key

      bastion_host        = var.use_bastion_service ? "host.bastion.${var.bastion_service_region}.oci.oraclecloud.com" : var.bastion_host
      bastion_user        = var.use_bastion_service ? oci_bastion_session.ssh_via_bastion_service[0].id : var.bastion_user
      bastion_private_key = var.bastion_private_key
    }

    inline = [
      "sleep 60",
      "chmod +x ~/setup.sh",
      "sudo ~/setup.sh",
    ]
  }
}

