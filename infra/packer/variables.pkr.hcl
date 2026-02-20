
variable "proxmox_endpoint" {
  type        = string
  description = "Proxmox VE endpoint"
  default     = "https://proxmox:8006"
}

variable "proxmox_username" {
  type        = string
  description = "Proxmox username"
  # sensitive   = true
}


variable "proxmox_node" {
  type        = string
  description = "Proxmox node name"
  default     = "pve"
}

variable "proxmox_storage" {
  type        = string
  description = "Proxmox storage pool"
  default     = "local"
}

variable "talos_version" {
  type    = string
  default = "v1.12.2"
}

variable "arch" {
  type    = string
  default = "amd64"
}

variable "server_type" {
  type    = string
  default = "cx23"
}

variable "server_location" {
  type    = string
  default = "hel1"
}

variable "proxmox_token" {
  type      = string
  sensitive = true
}

variable "proxmox_template_vm_id" {
  type        = string
  description = "VM ID for the Talos template"
  default = "2000"
}

variable "proxmox_storage_pool" {
  type        = string
  description = "Storage pool for the template disk"
  default = "local-fast2"
}

