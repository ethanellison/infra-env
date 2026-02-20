# infra-env

Deterministic infrastructure orchestration for Fedora Atomic systems.

## Purpose

`infra-env` provides a containerized toolbox ecosystem that enables consistent, reproducible development and infrastructure operations. It runs on Fedora Atomic (immutable host) using `toolbox` for environment isolation.

The system treats all environments as **cattle, not pets**: containers are built from Dockerfiles, created idempotently, and discarded when no longer needed. No manual modifications are permitted.

## Architecture

```
infra-env/
├── bootstrap/              # Phase 0: Host preparation
├── toolboxes/              # Container-based dev environments
├── scripts/                # Nushell automation (replaces Makefile)
├── infra/                  # Infrastructure as Code
│   ├── talos/             # Provider-agnostic Talos configs
│   ├── terraform/          # Terraform modules + environments
│   └── packer/             # Packer VM templates
├── testing/                # Cluster benchmarks
└── config/                # Shared configuration
```

## Quick Start

```bash
# Clone the repository
git clone https://github.com/ethanellison/infra-env.git
cd infra-env

# Run bootstrap
./bootstrap/bootstrap.sh
```

## Toolbox Operations

```nushell
# Build toolbox images
nu scripts/toolbox.nu build

# Create toolbox containers
nu scripts/toolbox.nu create

# Enter a toolbox
nu scripts/toolbox.nu enter infra
```

### Available Toolboxes

| Toolbox | Purpose |
|---------|---------|
| `dev` | General-purpose development |
| `cka` | CKA/CKAD exam preparation |
| `infra` | Infrastructure operations |

### dev - Development
General-purpose scripting and glue code.

```bash
nu scripts/toolbox.nu enter dev
```

Includes: Python, Go, Node.js, git, nushell, build tools

### cka - CKA/CKAD Exam
Kubernetes certification preparation environment.

```bash
nu scripts/toolbox.nu enter cka
```

Intentional minimalism:
- kubectl (v1.29.0, pinned)
- vim, less, nushell
- No aliases, helpers, or convenience tooling
- Discomfort is intentional to match exam environment

### infra - Infrastructure
Daily infrastructure and operations work.

```bash
nu scripts/toolbox.nu enter infra
```

Includes: kubectl, helm, kustomize, jq, yq, git, nushell, networking tools

## Infrastructure Operations

```nushell
# Terraform operations
nu scripts/infra.nu init staging
nu scripts/infra.nu plan prod
nu scripts/infra.nu apply staging
nu scripts/infra.nu get-configs prod

# Build Packer template
nu scripts/infra.nu build-template
```

## Cluster Management

```nushell
# Deploy cluster
nu scripts/cluster.nu deploy staging

# Check status
nu scripts/cluster.nu status prod
```

## Cattle Mindset

All environments are **disposable and reproducible**:

- **Containers are cattle**: Built from Dockerfiles, never modified after creation
- **No pets**: Do not maintain state in toolbox containers
- **Idempotent creation**: Safe to recreate containers at any time
- **Consistent behavior**: Same Dockerfile = same environment everywhere
- **No manual edits**: All tools installed via package manager or binary download during build

If a toolbox becomes unusable, destroy and recreate it:

```bash
toolbox rm -f dev
make enter-dev
```

## Technical Details

- **Base OS**: Fedora (latest) - atomic-compatible
- **Container Runtime**: podman
- **Toolbox Management**: toolbox (RHEL/Fedora feature)
- **Orchestration**: Nushell
- **Kubernetes**: Talos Linux (immutable, API-driven)
- **IaC**: Terraform (provider-agnostic architecture)

## Provider-Agnostic Architecture

Talos configurations are provider-agnostic:
- Base configs in `infra/talos/base/`
- Provider patches in `infra/talos/patches/providers/`
- Terraform modules: `talos-cluster` (config) + `{provider}-nodes` (infrastructure)

This enables the same Talos configs to work across HCloud, Proxmox, AWS, GCP with minimal changes.

## Design Principles

1. **Determinism**: Same input (Dockerfile) = same output (container)
2. **Immutability**: Containers created once, never modified
3. **Reproducibility**: Entire environment defined in git
4. **Simplicity**: Minimal layers, clear dependencies
5. **Cattle**: No hand-crafted snowflake systems