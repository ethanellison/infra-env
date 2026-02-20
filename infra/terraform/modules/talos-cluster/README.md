# talos-cluster

Provider-agnostic Talos Linux cluster configuration module.

## Purpose

This module handles all Talos-specific logic for bootstrapping and configuring a Talos Linux cluster, completely independent of the underlying infrastructure provider (HCloud, Proxmox, AWS, GCP, etc.).

## Architecture

The module separates concerns:

- **Infrastructure provisioning**: Handled by provider-specific modules (`hcloud-nodes`, `proxmox-nodes`)
- **Talos configuration**: Handled by this module (provider-agnostic)

This separation enables:
- Reusable Talos configuration across any provider
- Clean infrastructure-as-code organization
- Easier testing and maintenance

## Usage

```hcl
module "talos_cluster" {
  source = "../../modules/talos-cluster"

  cluster_name     = "production"
  cluster_endpoint = "https://1.2.3.4:6443"
  talos_version    = "v1.12.2"
  
  controlplane_ips = ["10.0.0.10"]
  worker_ips       = ["10.0.0.20", "10.0.0.21"]

  config_patches_controlplane = [
    file("${path.module}/../../../talos/patches/providers/hcloud.yaml")
  ]
  config_patches_worker = [
    file("${path.module}/../../../talos/patches/providers/hcloud.yaml")
  ]
}
```

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| cluster_name | Name of the Talos cluster | string | yes |
| cluster_endpoint | Kubernetes API endpoint (e.g., https://1.2.3.4:6443) | string | yes |
| controlplane_ips | List of control plane node IP addresses | list(string) | yes |
| talos_version | Talos Linux version | string | no (default: v1.12.2) |
| kubernetes_version | Kubernetes version | string | no (defaults to Talos bundled version) |
| worker_ips | List of worker node IP addresses | list(string) | no (default: []) |
| config_patches_controlplane | Additional config patches for control plane | list(string) | no (default: []) |
| config_patches_worker | Additional config patches for workers | list(string) | no (default: []) |
| talos_endpoints | Talos API endpoints | list(string) | no (defaults to controlplane_ips) |

## Outputs

| Name | Description |
|------|-------------|
| talosconfig | Talos client configuration content (sensitive) |
| kubeconfig | Kubernetes configuration content (sensitive) |
| cluster_endpoint | Kubernetes API endpoint |
| machine_configuration_controlplane | Talos machine configuration for control plane (sensitive) |
| machine_configuration_worker | Talos machine configuration for workers (sensitive) |

## Integration with Infrastructure Modules

The module must be composed with a provider-specific infrastructure module:

### HCloud Example

```hcl
module "hcloud_nodes" {
  source = "../../modules/hcloud-nodes"
  
  cluster_name       = "staging"
  controlplane_type  = "cx31"
  workers            = { ... }
  
  controlplane_user_data = module.talos_cluster.machine_configuration_controlplane
  worker_user_data       = module.talos_cluster.machine_configuration_worker
}

module "talos_cluster" {
  source = "../../modules/talos-cluster"
  
  cluster_name     = "staging"
  cluster_endpoint = module.hcloud_nodes.cluster_endpoint
  controlplane_ips = module.hcloud_nodes.controlplane_ips
  worker_ips       = module.hcloud_nodes.worker_ip_list
  
  config_patches_controlplane = [
    file("${path.module}/../../../talos/patches/providers/hcloud.yaml")
  ]
}
```

### Proxmox Example

```hcl
module "proxmox_nodes" {
  source = "../../modules/proxmox-nodes"
  
  cluster_name      = "production"
  control_planes    = 3
  workers           = 5
  control_plane_ips = ["192.168.1.10", "192.168.1.11", "192.168.1.12"]
  worker_ips        = ["192.168.1.20", "192.168.1.21", ...]
}

module "talos_cluster" {
  source = "../../modules/talos-cluster"
  
  cluster_name     = "production"
  cluster_endpoint = "https://192.168.1.10:6443"
  controlplane_ips = ["192.168.1.10", "192.168.1.11", "192.168.1.12"]
  worker_ips       = ["192.168.1.20", "192.168.1.21", ...]
  
  config_patches_controlplane = [
    file("${path.module}/../../../talos/patches/providers/proxmox.yaml")
  ]
}
```

## Provider-Specific Patches

Provider-specific configurations are applied via `config_patches_*` variables. These should reference YAML files in `infra/talos/patches/providers/`:

- `hcloud.yaml`: HCloud-specific settings (NTP servers, etc.)
- `proxmox.yaml`: Proxmox-specific settings

## Resources Created

This module creates:

- `talos_machine_secrets`: Cluster-wide secrets and certificates
- `talos_machine_configuration` (data): Control plane and worker configurations
- `talos_client_configuration` (data): Talos client configuration
- `talos_machine_bootstrap`: One-time cluster bootstrap operation
- `talos_cluster_kubeconfig`: Kubernetes client configuration

## Cattle Mindset

This module follows the cattle-not-pets principle:

- All configuration is declarative and version-controlled
- No manual talosctl operations (everything via Terraform)
- Clusters can be destroyed and recreated reliably
- State is immutable (changes require Terraform apply)
