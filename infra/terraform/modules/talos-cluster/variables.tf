variable "cluster_name" {
  type        = string
  description = "Name of the Talos cluster"
}

variable "cluster_endpoint" {
  type        = string
  description = "Kubernetes API endpoint (e.g., https://1.2.3.4:6443)"
}

variable "talos_version" {
  type        = string
  description = "Talos Linux version"
  default     = "v1.12.2"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version (defaults to version bundled with Talos)"
  default     = null
}

variable "controlplane_ips" {
  type        = list(string)
  description = "List of control plane node IP addresses"
}

variable "worker_ips" {
  type        = list(string)
  description = "List of worker node IP addresses (optional for config generation)"
  default     = []
}

variable "generate_worker_config" {
  type        = bool
  description = "Whether to generate worker config (even without worker_ips)"
  default     = true
}

variable "config_patches_controlplane" {
  type        = list(string)
  description = "Additional config patches for control plane nodes"
  default     = []
}

variable "config_patches_worker" {
  type        = list(string)
  description = "Additional config patches for worker nodes"
  default     = []
}

variable "talos_endpoints" {
  type        = list(string)
  description = "Talos API endpoints (defaults to controlplane_ips)"
  default     = null
}
