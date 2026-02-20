output "control_plane_ips" {
  description = "Static IPs of control plane nodes"
  value       = var.control_plane_ips
}

output "worker_ips" {
  description = "Static IPs of worker nodes"
  value       = var.worker_ips
}

output "control_plane_vm_ids" {
  description = "VM IDs of control plane nodes"
  value       = proxmox_virtual_environment_vm.control_plane[*].vm_id
}

output "worker_vm_ids" {
  description = "VM IDs of worker nodes"
  value       = proxmox_virtual_environment_vm.worker[*].vm_id
}

output "talosconfig" {
  description = "Talos configuration file content"
  value       = data.talos_client_configuration.this.talos_config
  sensitive   = true
}

output "kubeconfig" {
  description = "Kubernetes configuration file content"
  value       = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive   = true
}

output "cluster_endpoint" {
  description = "Kubernetes API endpoint"
  value       = "https://${var.control_plane_ips[0]}:6443"
}
