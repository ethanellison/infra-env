variable "cluster_name" {
  type        = string
  description = "Name of the cluster"
}

variable "network_name" {
  type        = string
  description = "Name of the private network"
  default     = "talos-network"
}

variable "network_ip_range" {
  type        = string
  description = "CIDR range for the private network"
  default     = "10.0.0.0/16"
}

variable "subnet_ip_range" {
  type        = string
  description = "CIDR range for the subnet"
  default     = "10.0.0.0/24"
}

variable "network_zone" {
  type        = string
  description = "Hetzner network zone"
  default     = "eu-central"
}

variable "load_balancer_type" {
  type        = string
  description = "Load balancer type"
  default     = "lb11"
}

variable "controlplane_type" {
  type        = string
  description = "Server type for control plane"
}

variable "controlplane_location" {
  type        = string
  description = "Location for control plane"
}

variable "controlplane_ip" {
  type        = string
  description = "Private IP for control plane"
  default     = "10.0.0.3"
}

variable "workers" {
  type = map(object({
    server_type = string
    location    = string
  }))
  description = "Map of worker definitions"
}

variable "talos_image_id" {
  type        = string
  description = "Hetzner Cloud image ID for Talos Linux (custom snapshot)"
}

variable "talos_version" {
  type        = string
  description = "Talos version"
}

variable "kubernetes_version" {
  type        = string
  default     = null
  description = "Kubernetes version (defaults to Talos bundled)"
}

variable "controlplane_user_data" {
  type        = string
  description = "User data for control plane (Talos machine configuration)"
  default     = ""
}

variable "worker_user_data" {
  type        = string
  description = "User data for workers (Talos machine configuration)"
  default     = ""
}

variable "cluster_endpoint" {
  type        = string
  description = "Kubernetes API endpoint for worker nodes"
  default     = ""
}
