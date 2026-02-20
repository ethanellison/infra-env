output "talosconfig" {
  description = "Talos client configuration content"
  value       = data.talos_client_configuration.this.talos_config
  sensitive   = true
}

output "kubeconfig" {
  description = "Kubernetes configuration content"
  value       = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive   = true
}

output "cluster_endpoint" {
  description = "Kubernetes API endpoint"
  value       = var.cluster_endpoint
}

output "machine_configuration_controlplane" {
  description = "Talos machine configuration for control plane nodes"
  value       = data.talos_machine_configuration.controlplane.machine_configuration
  sensitive   = true
}

output "machine_configuration_worker" {
  description = "Talos machine configuration for worker nodes (list, use first element)"
  value       = data.talos_machine_configuration.worker[*].machine_configuration
  sensitive   = true
}
