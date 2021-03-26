locals {
  name_suffix = "${var.resource_tags["project"]}-${var.resource_tags["environment"]}"
}

terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.6.3"
    }
  }
}

# instance the provider
provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_pool" "ubuntu_pool" {
  name = "ubuntu_pool"
  type = "dir"
  #path = "/tmp/terraform-provider-libvirt-pool-ubuntu"
  path = var.storage_pool
}

# We fetch the latest ubuntu release image from their mirrors
resource "libvirt_volume" "vol_server" {
  count = var.cant_instances
  name = "vol_server${count.index}"
  pool = libvirt_pool.ubuntu_pool.name
  source = var.source_img
  format = "qcow2"
}

data "template_file" "user_data" {
  template = file("${path.module}/cloud-config.cfg")
}

#data "template_file" "passwd_config" {
#  template = file("${path.module}/passwd_config.cfg")
#}

# for more info about paramater check this out
# https://github.com/dmacvicar/terraform-provider-libvirt/blob/master/website/docs/r/cloudinit.html.markdown
# Use CloudInit to add our ssh-key to the instance
# you can add also meta_data field
resource "libvirt_cloudinit_disk" "cloudinit-ubuntu" {
  name      = "cloudinit-ubuntu.iso"
  user_data = data.template_file.user_data.rendered
  pool      = libvirt_pool.ubuntu_pool.name
}

# Create the machine
resource "libvirt_domain" "server" {
  count = var.cant_instances
  name = "server${count.index}-${local.name_suffix}"
  memory = var.instance_mem
  vcpu   = var.instance_cpu

  cloudinit = libvirt_cloudinit_disk.cloudinit-ubuntu.id

  network_interface {
    network_name = "default"
  }

  # IMPORTANT: this is a known bug on cloud images, since they expect a console
  # we need to pass it
  # https://bugs.launchpad.net/cloud-images/+bug/1573095
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.vol_server[count.index].id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

#terraform {
#  required_version = ">= 0.12"
#}

# IPs: use wait_for_lease true or after creation use terraform refresh and terraform show for the ips of domain
