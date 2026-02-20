# Packer Configurations

This directory contains Packer configurations for building Talos Linux images.

## Overview

Packer is used to create VM templates for the on-premise Proxmox infrastructure. Hetzner Cloud deployments use Talos Image Factory instead.

## Active Configurations

### `proxmox.pkr.hcl`
Builds Talos Linux templates for Proxmox VE.

**Features:**
- Uses Talos Image Factory to download the latest nocloud image
- Creates a template VM with ID 2000 (configurable via `proxmox_template_vm_id`)
- Supports configurable storage pools
- Includes qemu-guest-agent

**Variables:**
| Variable | Default | Description |
|----------|---------|-------------|
| `proxmox_endpoint` | `https://proxmox:8006` | Proxmox API endpoint |
| `proxmox_username` | - | Proxmox username |
| `proxmox_token` | - | Proxmox API token |
| `proxmox_node` | `pve` | Proxmox node name |
| `proxmox_storage` | `local` | Storage pool for VM disks |
| `proxmox_template_vm_id` | `2000` | VM ID for the template |
| `proxmox_storage_pool` | `local-fast2` | Storage pool for template disk |
| `talos_version` | `v1.12.2` | Talos version to install |

**Usage:**
```bash
# Set required variables
export PKR_VAR_proxmox_username="root@pam"
export PKR_VAR_proxmox_token="your-api-token"

# Build template
make packer-build-proxmox
# OR
cd packer && packer build proxmox.pkr.hcl
```

## Deprecated Configurations

### `deprecated/hcloud.pkr.hcl.deprecated`
Previously used to build Talos images for Hetzner Cloud.

**Status:** Deprecated - no longer needed

**Reason:** Hetzner Cloud deployments now use Talos Image Factory directly, which provides pre-built images with the Hetzner + qemu-guest-agent schematic.

## Directory Structure

```
packer/
├── README.md                          # This file
├── proxmox.pkr.hcl                    # Active: Proxmox template builder
├── variables.pkr.hcl                  # Packer variables
├── vars.auto.pkrvars.hcl              # Auto-loaded variables (not in git)
├── vars.auto.pkrvars.hcl.example      # Example variables file
├── mise.toml                          # Mise configuration
└── deprecated/
    └── hcloud.pkr.hcl.deprecated      # Deprecated: HCloud builder
```

## Quick Start

1. Copy example variables:
   ```bash
   cp vars.auto.pkrvars.hcl.example vars.auto.pkrvars.hcl
   ```

2. Edit `vars.auto.pkrvars.hcl` with your Proxmox credentials

3. Build the template:
   ```bash
   make packer-build-proxmox
   ```

4. Verify the template appears in Proxmox (VM ID 2000)

## Talos Image Factory

Both configurations use the Talos Image Factory to download official images:

- **Schematic ID:** `ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515`
- **Components:** Talos + qemu-guest-agent
- **Platform:** nocloud (for Proxmox)

For more information, visit: https://factory.talos.dev

## Notes

- The Proxmox template (VM ID 2000) must exist before running Terraform
- Template updates require rebuilding with Packer
- Keep template versions in sync with `talos_version` in Terraform
