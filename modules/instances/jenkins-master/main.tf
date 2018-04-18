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

## JENKINS MASTER INSTANCE(S)

resource "oci_core_instance" "TFJenkinsMaster" {
  availability_domain = "${var.availability_domain}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "${var.label_prefix}${var.display_name_prefix}"
  hostname_label      = "${var.hostname_label_prefix}"
  image               = "${lookup(data.oci_core_images.ImageOCID.images[0], "id")}"
  shape               = "${var.shape}"

  create_vnic_details {
    subnet_id        = "${var.subnet_id}"
    display_name     = "${var.label_prefix}${var.display_name_prefix}"
    assign_public_ip = true
    hostname_label   = "${var.hostname_label_prefix}"
  }

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
  }

  provisioner "file" {
    connection = {
      host        = "${self.public_ip}"
      agent       = false
      timeout     = "30m"
      user        = "opc"
      private_key = "${var.ssh_private_key}"
    }

    content     = "${var.setup_data}"
    destination = "/tmp/setup.sh"
  }

  provisioner "remote-exec" {
    connection = {
      host        = "${self.public_ip}"
      agent       = false
      timeout     = "30m"
      user        = "opc"
      private_key = "${var.ssh_private_key}"
    }

    inline = [
      "chmod +x /tmp/setup.sh",
      "sudo /tmp/setup.sh",
    ]
  }

  timeouts {
    create = "60m"
  }
}
