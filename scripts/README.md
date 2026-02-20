# Scripts

Operational automation using Nushell. Replaces Makefile targets with type-safe, cross-platform Nushell scripts.

## Overview

- `toolbox.nu` - Toolbox build/create/enter operations
- `infra.nu` - Terraform and Packer operations
- `cluster.nu` - Cluster deployment and management
- `lib/` - Shared utilities

## Quick Start

```nushell
# Toolbox operations
nu scripts/toolbox.nu help
nu scripts/toolbox.nu build
nu scripts/toolbox.nu enter infra

# Infrastructure operations
nu scripts/infra.nu help
nu scripts/infra.nu init staging
nu scripts/infra.nu plan prod
nu scripts/infra.nu apply staging

# Cluster operations
nu scripts/cluster.nu help
nu scripts/cluster.nu deploy staging
nu scripts/cluster.nu status prod
```

## Design Principles

1. **Idempotent**: Safe to run multiple times
2. **Composable**: Scripts can call each other
3. **Type-safe**: Nushell provides structured data and type checking
4. **Self-documenting**: Use `help` subcommand for each script
