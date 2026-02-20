packer {
  required_plugins {
    name = {
      version = "~> 1"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

locals {
  timestamp = timestamp()
  image = "https://factory.talos.dev/image/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515/${var.talos_version}/nocloud-amd64.raw.xz"
}

source "proxmox-iso" "talos" {
  proxmox_url          = var.proxmox_endpoint
  username             = var.proxmox_username
  token                = var.proxmox_token
  node                 = var.proxmox_node
  insecure_skip_tls_verify = true
  
  # Boot arch
  boot_iso {
    type = "scsi"
    iso_file = "local:iso/archlinux-2026.01.01-x86_64.iso"
    unmount = true
  }

  # VM settings
  vm_name              = "talos-template-${var.talos_version}"
  vm_id                = var.proxmox_template_vm_id
  memory               = 4096
  cores                = 4
  cpu_type             = "host"
  sockets              = 1
  
  # Network
  network_adapters {
    model  = "virtio"
    bridge = "vmbr0"
  }
  
  # Storage
  scsi_controller = "virtio-scsi-pci"
  
  disks {
    type             = "virtio"
    disk_size        = "50G"
    storage_pool     = var.proxmox_storage_pool
  }
  
  # cloud_init = true
  qemu_agent = true
  
  ssh_username = "root"
  ssh_password = "packer"
  ssh_timeout  = "10m"
  
  boot_wait = "20s"
  boot_command = [
    "<enter><wait50s>",
    "passwd<enter><wait1s>packer<enter><wait1s>packer<enter>",
  ]
  # Convert to template after build
  template_name        = "talos-${var.talos_version}"
  template_description = "Talos ${var.talos_version} - Built ${local.timestamp}"

}

build {
  sources = ["source.proxmox-iso.talos"]

  provisioner "shell" {
    inline = [
      "curl -kL \"${local.image}\" -o /tmp/talos.raw.xz",
      "xz -d -c /tmp/talos.raw.xz | dd of=/dev/vda && sync",
    ]
  }
}
