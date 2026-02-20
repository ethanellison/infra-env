variable "hcloud_token" {
  type        = string
  sensitive   = true
  description = "Hetzner Cloud API token"
}

variable "cluster_name" {
  type        = string
  default     = "talos-staging"
  description = "Name of the staging cluster"
}

variable "talos_version" {
  type        = string
  default     = "v1.12.2"
  description = "Talos version (must match packer build)"
}

variable "hcloud_location" {
  type        = string
  default     = "fsn1"
  description = "Hetzner Cloud location"
}

variable "cp_server_type" {
  type        = string
  default     = "cx31"
  description = "Control plane server type"
}

variable "worker_server_type" {
  type        = string
  default     = "cx21"
  description = "Worker server type"
}

variable "workers" {
  type = map(object({
    server_type = string
    location    = string
  }))
  description = "Map of worker definitions"
  default = {
    "worker-1" = { server_type = "cx21", location = "fsn1" }
    "worker-2" = { server_type = "cx21", location = "fsn1" }
  }
}

variable "talos_image_id" {
  type        = string
  default     = "355830887"
  description = "Hetzner Cloud image ID for Talos Linux snapshot"
}
