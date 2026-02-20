variable "cluster_name" {
  type        = string
  description = "Name of the cluster"
}

variable "proxmox_endpoint" {
  type = string
}
variable "talos_version" {
  type        = string
  description = "Talos version"
}

variable "kubernetes_version" {
  type        = string
  default     = null
  description = "Kubernetes version (defaults to version bundled with Talos)"
}

variable "proxmox_node" {
  type        = string
  description = "Proxmox node name"
}

variable "proxmox_storage" {
  type        = string
  description = "Proxmox storage pool for VMs"
}

variable "control_planes" {
  type        = number
  description = "Number of control plane nodes"
}

variable "workers" {
  type        = number
  description = "Number of worker nodes"
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
  description = "Static IPs for control plane nodes"
}

variable "worker_ips" {
  type        = list(string)
  description = "Static IPs for worker nodes"
}

variable "gateway" {
  type        = string
  description = "Network gateway IP"
}

variable "nameservers" {
  type        = list(string)
  default     = ["1.1.1.1", "8.8.8.8"]
  description = "DNS nameservers"
}
