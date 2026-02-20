output "control_plane_ips" {
  description = "Static IPs of control plane nodes"
  value       = module.proxmox_nodes.control_plane_ips
}

output "worker_ips" {
  description = "Static IPs of worker nodes"
  value       = module.proxmox_nodes.worker_ips
}

output "control_plane_vm_ids" {
  description = "VM IDs of control plane nodes"
  value       = module.proxmox_nodes.control_plane_vm_ids
}

output "worker_vm_ids" {
  description = "VM IDs of worker nodes"
  value       = module.proxmox_nodes.worker_vm_ids
}

output "api_endpoint" {
  description = "Kubernetes API endpoint (use first control plane IP or your own LB)"
  value       = "https://${var.control_plane_ips[0]}:6443"
}

output "talosconfig" {
  description = "Talos configuration file content"
  value       = module.proxmox_nodes.talosconfig
  sensitive   = true
}

output "kubeconfig" {
  description = "Kubernetes configuration file content"
  value       = module.proxmox_nodes.kubeconfig
  sensitive   = true
}
