# Init Script Files
data "template_file" "config_agent" {
  template = file("${path.module}/scripts/config.sh")

  vars = {
    jenkins_controller_url = local.jenkins_controller_url
    jenkins_password       = var.jenkins_password
  }
}

locals {
  jenkins_controller_url = "http://${var.jenkins_controller_ip}:${var.jenkins_controller_port}"
}

# Jenkins agents
resource "oci_core_instance" "TFJenkinsAgent" {
  count               = var.number_of_agents
  availability_domain = var.availability_domains[count.index % length(var.availability_domains)]
  compartment_id      = var.compartment_ocid
  display_name        = "${var.label_prefix}${var.agent_display_name}-${count.index + 1}"
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
    subnet_id        = var.subnet_ids[count.index % length(var.subnet_ids)]
    display_name     = "${var.label_prefix}${var.agent_display_name}-${count.index + 1}"
    assign_public_ip = false
    hostname_label   = "${var.agent_display_name}-${count.index + 1}"
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
  count      = var.use_bastion_service ? var.number_of_agents : 0
  bastion_id = var.bastion_service_id

  key_details {
    public_key_content = var.bastion_authorized_keys
  }

  target_resource_details {
    session_type                               = "MANAGED_SSH"
    target_resource_id                         = oci_core_instance.TFJenkinsAgent[count.index].id
    target_resource_operating_system_user_name = "opc"
    target_resource_port                       = 22
    target_resource_private_ip_address         = oci_core_instance.TFJenkinsAgent[count.index].private_ip
  }

  display_name           = "ssh_via_bastion_service"
  key_type               = "PUB"
  session_ttl_in_seconds = 1800
}


resource "null_resource" "TFJenkinsAgentConfig" {
  depends_on = [oci_core_instance.TFJenkinsAgent]
  count      = var.number_of_agents

  provisioner "file" {
    connection {
      host        = oci_core_instance.TFJenkinsAgent[count.index].private_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key

      bastion_host        = var.use_bastion_service ? "host.bastion.${var.bastion_service_region}.oci.oraclecloud.com" : var.bastion_host
      bastion_user        = var.use_bastion_service ? oci_bastion_session.ssh_via_bastion_service[count.index].id : var.bastion_user
      bastion_private_key = var.bastion_private_key
    }

    content     = data.template_file.config_agent.rendered
    destination = "~/config_agent.sh"
  }

  # Register & Launch agent
  provisioner "remote-exec" {
    connection {
      host        = oci_core_instance.TFJenkinsAgent[count.index].private_ip
      agent       = false
      timeout     = "10m"
      user        = var.vm_user
      private_key = var.ssh_private_key

      bastion_host        = var.use_bastion_service ? "host.bastion.${var.bastion_service_region}.oci.oraclecloud.com" : var.bastion_host
      bastion_user        = var.use_bastion_service ? oci_bastion_session.ssh_via_bastion_service[count.index].id : var.bastion_user
      bastion_private_key = var.bastion_private_key
    }

    inline = [
      "sleep 60",
      "sudo chmod +x ~/config_agent.sh",
      "sudo ~/config_agent.sh ${oci_core_instance.TFJenkinsAgent[count.index].display_name}",
    ]
  }
}

