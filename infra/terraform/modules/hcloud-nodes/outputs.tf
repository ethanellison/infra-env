output "cluster_endpoint" {
  description = "Kubernetes API endpoint (load balancer IP)"
  value       = "https://${hcloud_load_balancer.controlplane.ipv4}:6443"
}

output "load_balancer_ip" {
  description = "Load balancer public IP"
  value       = hcloud_load_balancer.controlplane.ipv4
}

output "controlplane_ip" {
  description = "Control plane public IP"
  value       = hcloud_server.controlplane.ipv4_address
}

output "controlplane_private_ip" {
  description = "Control plane private IP"
  value       = var.controlplane_ip
}

output "worker_ips" {
  description = "Worker node public IPs"
  value       = { for k, v in hcloud_server.worker : k => v.ipv4_address }
}

output "network_id" {
  description = "Private network ID"
  value       = hcloud_network.network.id
}

output "controlplane_id" {
  description = "Control plane server ID"
  value       = hcloud_server.controlplane.id
}

output "worker_ids" {
  description = "Worker server IDs"
  value       = { for k, v in hcloud_server.worker : k => v.id }
}

output "controlplane_ips" {
  description = "List of control plane IPs for talos-cluster module"
  value       = [hcloud_server.controlplane.ipv4_address]
}

output "worker_ip_list" {
  description = "List of worker IPs for talos-cluster module"
  value       = [for k, v in hcloud_server.worker : v.ipv4_address]
}
