output "talosconfig" {
  description = "Talos configuration file content"
  value       = module.talos_cluster.talosconfig
  sensitive   = true
}

output "kubeconfig" {
  description = "Kubernetes configuration file content"
  value       = module.talos_cluster.kubeconfig
  sensitive   = true
}

output "cluster_endpoint" {
  description = "Kubernetes API endpoint"
  value       = module.hcloud_nodes.cluster_endpoint
}

output "load_balancer_ip" {
  description = "Load balancer public IP"
  value       = module.hcloud_nodes.load_balancer_ip
}

output "control_plane_ip" {
  description = "Control plane public IP"
  value       = module.hcloud_nodes.controlplane_ip
}

output "worker_ips" {
  description = "Worker node public IPs"
  value       = module.hcloud_nodes.worker_ips
}
