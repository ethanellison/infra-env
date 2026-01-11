# infra-env

Deterministic infrastructure orchestration for Fedora Atomic systems.

## Purpose

`infra-env` provides a containerized toolbox ecosystem that enables consistent, reproducible development and infrastructure operations. It runs on Fedora Atomic (immutable host) using `toolbox` for environment isolation.

The system treats all environments as **cattle, not pets**: containers are built from Dockerfiles, created idempotently, and discarded when no longer needed. No manual modifications are permitted.

## Architecture

- **Phase 0 (bootstrap.sh)**: System preparation - installs podman, toolbox, nushell, and required dependencies via rpm-ostree
- **Phase 1 (bootstrap.nu)**: Environment orchestration - builds toolbox images and creates containers idempotently

## Quick Start

```bash
# Clone the repository
git clone https://github.com/ethanellison/infra-env.git
cd infra-env

# Run bootstrap
./bootstrap/bootstrap.sh
```

## Toolboxes

### dev - Development
General-purpose scripting and glue code.

```bash
make enter-dev
```

Includes: Python, Go, Node.js, git, nushell, build tools

### cka - CKA/CKAD Exam
Kubernetes certification preparation environment.

```bash
make enter-cka
```

Intentional minimalism:
- kubectl (v1.29.0, pinned)
- vim, less, nushell
- No aliases, helpers, or convenience tooling
- Discomfort is intentional to match exam environment

### infra - Infrastructure
Daily infrastructure and operations work.

```bash
make enter-infra
```

Includes: kubectl, helm, kustomize, jq, yq, git, nushell, networking tools

## Makefile Targets

```bash
make help              # Display all targets
make build-toolboxes  # Build container images
make create-toolboxes # Create toolboxes (idempotent)
make enter-infra      # Enter infra toolbox
make enter-cka        # Enter cka toolbox
make enter-dev        # Enter dev toolbox
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
- **All tools**: Non-interactive installation via dnf or binary download

## Design Principles

1. **Determinism**: Same input (Dockerfile) = same output (container)
2. **Immutability**: Containers created once, never modified
3. **Reproducibility**: Entire environment defined in git
4. **Simplicity**: Minimal layers, clear dependencies
5. **Cattle**: No hand-crafted snowflake systems