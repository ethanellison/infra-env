terraform {
  required_version = ">= 1.6"
}

module "proxmox_nodes" {
  source = "../../modules/proxmox-nodes"

  cluster_name      = var.cluster_name
  talos_version     = var.talos_version
  proxmox_node      = var.proxmox_node
  proxmox_storage   = var.proxmox_storage
  proxmox_endpoint  = var.proxmox_endpoint
  control_planes    = 1
  workers           = 2
  cp_memory         = var.cp_memory
  cp_cores          = var.cp_cores
  worker_memory     = var.worker_memory
  worker_cores      = var.worker_cores
  disk_size         = var.disk_size
  network_bridge    = var.network_bridge
  control_plane_ips = var.control_plane_ips
  worker_ips        = var.worker_ips
  gateway           = var.gateway
  nameservers       = var.nameservers
}
