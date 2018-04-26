## DATASOURCE
# Prevent oci_core_images image list from changing underneath us.
data "oci_core_images" "ImageOCID" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "${var.master_ol_image_name}"
}

## JENKINS MASTER INSTANCE(S)
resource "oci_core_instance" "TFJenkinsMaster" {
  availability_domain = "${var.availability_domain}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "${var.label_prefix}${var.master_display_name}"
  shape               = "${var.shape}"

  create_vnic_details {
    subnet_id        = "${var.subnet_id}"
    display_name     = "${var.label_prefix}${var.master_display_name}"
    assign_public_ip = "${var.assign_public_ip}"
    hostname_label   = "${var.master_display_name}"
  }

  metadata {
    ssh_authorized_keys = "${file("${var.ssh_authorized_keys}")}"
  }

  source_details {
    source_id   = "${lookup(data.oci_core_images.ImageOCID.images[0], "id")}"
    source_type = "image"
  }

  provisioner "file" {
    connection = {
      host        = "${self.public_ip}"
      agent       = false
      timeout     = "5m"
      user        = "opc"
      private_key = "${file("${var.ssh_private_key}")}"
    }

    content     = "${var.setup_data}"
    destination = "/tmp/setup.sh"
  }

  provisioner "remote-exec" {
    connection = {
      host        = "${self.public_ip}"
      agent       = false
      timeout     = "5m"
      user        = "opc"
      private_key = "${file("${var.ssh_private_key}")}"
    }

    inline = [
      "chmod +x /tmp/setup.sh",
      "sudo /tmp/setup.sh",
    ]
  }

  timeouts {
    create = "10m"
  }
}
