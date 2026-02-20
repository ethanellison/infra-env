variable "proxmox_endpoint" {
  type        = string
  description = "Proxmox VE API endpoint URL"
}

variable "proxmox_username" {
  type        = string
  sensitive   = true
  description = "Proxmox username"
}

variable "proxmox_password" {
  type        = string
  sensitive   = true
  description = "Proxmox password"
}

variable "cluster_name" {
  type        = string
  default     = "talos-prod"
  description = "Name of the production cluster"
}

variable "talos_version" {
  type        = string
  default     = "v1.12.2"
  description = "Talos version (must match packer build)"
}

variable "proxmox_node" {
  type        = string
  description = "Proxmox node name"
}

variable "proxmox_storage" {
  type        = string
  description = "Proxmox storage pool for VMs"
}


variable "cp_memory" {
  type        = number
  default     = 4096
  description = "Memory for control plane nodes (MB)"
}

variable "cp_cores" {
  type        = number
  default     = 4
  description = "CPU cores for control plane nodes"
}

variable "worker_memory" {
  type        = number
  default     = 8192
  description = "Memory for worker nodes (MB)"
}

variable "worker_cores" {
  type        = number
  default     = 4
  description = "CPU cores for worker nodes"
}

variable "disk_size" {
  type        = number
  default     = 50
  description = "Disk size in GB"
}

variable "network_bridge" {
  type        = string
  default     = "vmbr0"
  description = "Proxmox network bridge"
}

variable "control_plane_ips" {
  type        = list(string)
  description = "Static IPs for 3 control plane nodes (e.g., [\"192.168.0.11\", \"192.168.0.12\", \"192.168.0.13\"])"
}

variable "worker_ips" {
  type        = list(string)
  description = "Static IPs for 3 worker nodes (e.g., [\"192.168.0.21\", \"192.168.0.22\", \"192.168.0.23\"])"
}

variable "gateway" {
  type        = string
  description = "Network gateway IP (e.g., 192.168.0.1)"
}

variable "nameservers" {
  type        = list(string)
  default     = ["1.1.1.1", "8.8.8.8"]
  description = "DNS nameservers"
}
