terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.60.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = ">= 0.5.0"
    }
  }
}

# Lookup the Talos template created by Packer
data "proxmox_virtual_environment_vm" "talos_template" {
  node_name = var.proxmox_node
  vm_id     = 2000
}

# Control Plane VMs with Talos config snippet
resource "proxmox_virtual_environment_vm" "control_plane" {
  count     = var.control_planes
  name      = "${var.cluster_name}-cp-${count.index + 1}"
  node_name = var.proxmox_node

  clone {
    vm_id        = data.proxmox_virtual_environment_vm.talos_template.vm_id
    datastore_id = "local-fast2"
    full         = true
  }

  agent {
    enabled = true
  }

  cpu {
    cores   = var.cp_cores
    sockets = 1
    type    = "host"
  }

  memory {
    dedicated = var.cp_memory
  }

  disk {
    interface = "virtio0"
    size      = var.disk_size
    iothread  = true
    discard   = "on"
  }

  network_device {
    bridge = var.network_bridge
    model  = "virtio"
  }

  # Static IP configuration via cloud-init + Talos config via snippet
  initialization {
    ip_config {
      ipv4 {
        address = "${var.control_plane_ips[count.index]}/24"
        gateway = var.gateway
      }
    }

    dns {
      servers = var.nameservers
    }

    user_data_file_id = proxmox_virtual_environment_file.controlplane_config.id
  }

  on_boot = true

  depends_on = [
    proxmox_virtual_environment_file.controlplane_config
  ]
}

# Update Worker VMs to use Talos config snippets
resource "proxmox_virtual_environment_vm" "worker" {
  count     = var.workers
  name      = "${var.cluster_name}-worker-${count.index + 1}"
  node_name = var.proxmox_node

  clone {
    vm_id        = data.proxmox_virtual_environment_vm.talos_template.vm_id
    full         = true
    datastore_id = "local-fast2"
  }

  agent {
    enabled = true
  }

  cpu {
    cores   = var.worker_cores
    sockets = 1
    type    = "host"
  }

  memory {
    dedicated = var.worker_memory
  }

  disk {
    interface = "virtio0"
    size      = var.disk_size
    iothread  = true
    discard   = "on"
  }

  network_device {
    bridge = var.network_bridge
    model  = "virtio"
  }

  # Static IP configuration via cloud-init + Talos config via snippet
  initialization {
    ip_config {
      ipv4 {
        address = "${var.worker_ips[count.index]}/24"
        gateway = var.gateway
      }
    }

    dns {
      servers = var.nameservers
    }

    user_data_file_id = proxmox_virtual_environment_file.worker_config[count.index].id
  }

  on_boot = true
}


# Talos Machine Secrets
resource "talos_machine_secrets" "this" {
  talos_version = var.talos_version
}

# Talos Machine Configuration - Control Plane
data "talos_machine_configuration" "controlplane" {
  cluster_name       = var.cluster_name
  cluster_endpoint   = "https://${var.control_plane_ips[0]}:6443"
  machine_type       = "controlplane"
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version

  config_patches = [
    templatefile("${path.module}/templates/controlplane.yaml.tmpl", {
      ip      = var.control_plane_ips[0]
      gateway = var.gateway
    })
  ]
}

# Talos Machine Configuration - Workers (one per worker for unique IPs)
data "talos_machine_configuration" "worker" {
  count = var.workers

  cluster_name       = var.cluster_name
  cluster_endpoint   = "https://${var.control_plane_ips[0]}:6443"
  machine_type       = "worker"
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version

  config_patches = [
    templatefile("${path.module}/templates/worker.yaml.tmpl", {
      ip      = var.worker_ips[count.index]
      gateway = var.gateway
    })
  ]
}

# Upload Talos configuration snippets to Proxmox
resource "proxmox_virtual_environment_file" "controlplane_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.proxmox_node

  source_raw {
    data      = data.talos_machine_configuration.controlplane.machine_configuration
    file_name = "${var.cluster_name}-controlplane.yaml"
  }
}

resource "proxmox_virtual_environment_file" "worker_config" {
  count = var.workers

  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.proxmox_node

  source_raw {
    data      = data.talos_machine_configuration.worker[count.index].machine_configuration
    file_name = "${var.cluster_name}-worker-${count.index + 1}.yaml"
  }
}


# Bootstrap the cluster
data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = var.control_plane_ips
  nodes                = var.control_plane_ips
}

resource "talos_machine_bootstrap" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoint             = var.control_plane_ips[0]
  node                 = var.control_plane_ips[0]

  depends_on = [
    proxmox_virtual_environment_vm.control_plane
  ]
}

resource "talos_cluster_kubeconfig" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = var.control_plane_ips[0]

  depends_on = [
    talos_machine_bootstrap.this
  ]
}
