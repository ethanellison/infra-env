# AGENTS.md - Automation Guidelines

This document specifies the cattle mindset for agents and automation within infra-env.

## Cattle Mindset Principle

All infrastructure and environments are disposable, reproducible, and immutable.

- Treat containers as cattle, not pets: do not modify running containers after deployment.
- Build images from Dockerfiles; change goes Dockerfile → commit → rebuild → redeploy.
- No manual package installs inside running containers; all install logic must be in image builds.
- Operations must be idempotent and non-interactive.

## Bootstrap (Phase 0)

Purpose: prepare the host system to run Nushell-based orchestration.

Rules:
- Use `rpm-ostree` to install host packages.
- Install only base dependencies: `podman`, `toolbox`, `nushell`, `git`, `curl`, `wget`.
- Detect and exit if a reboot is required.
- Clone the repository to `~/.infra-env` if not present and transfer control to `bootstrap/bootstrap.nu`.
- Must be safe to re-run.

Prohibited: cluster logic, toolbox logic, interactive prompts, conditional feature flags.

## Orchestration (Phase 1)

Purpose: build toolbox images and create toolboxes idempotently.

Rules:
- Build all toolbox images from Dockerfiles.
- Create toolboxes idempotently (skip creation if they already exist).
- Fail fast on error and print clear completion instructions.
- Must be safe to re-run.

Prohibited: interactive prompts, manual container modifications, in-place updates.

## Toolbox Management

Rules:
- All toolboxes are container-based and built with `podman`.
- All toolboxes are defined via Dockerfiles.
- All tools must be installed non-interactively during image build.
- No toolbox may be modified interactively after creation.
- If a toolbox is broken: remove and recreate from its Dockerfile.

## Dockerfile Rules

All Dockerfiles must:
- Use `FROM fedora:latest` as base.
- Install packages with `dnf install -y ... && dnf clean all`.
- Avoid interactive prompts and user input.
- Include `WORKDIR /workspace` and a `CMD` or `ENTRYPOINT`.
- Avoid commented-out code, TODOs, or explanatory prose beyond inline directives.

## Git Commits

All commits must:
- Be made after file changes are complete.
- Include a descriptive commit message.
- Contain production-ready code only (no TODOs or commented debugging code).

## Infrastructure as Code (IaC)

Purpose: declarative management of Kubernetes clusters using Talos Linux.

Rules:
- All infrastructure changes must be made via Terraform configurations.
- Use modules for reusable components (proxmox-nodes, hcloud-nodes, talos-cluster).
- Provider-agnostic Talos config lives in `infra/talos/`.
- Environment-specific values belong in `infra/terraform/environments/<env>/`.
- Never manually modify running VMs; changes require Terraform updates → commit → apply.
- Static IP assignments must be documented in `terraform.tfvars`.

Prohibited: manual VM modifications, manual talosctl operations, editing state files.

### Terraform Guidelines

- Use `terraform plan` before every apply to review changes.
- Store sensitive values in `terraform.tfvars` (gitignored), never in `.tf` files.
- Output `kubeconfig` and `talosconfig` to environment directories.
- Use Nushell scripts for standardized operations (`nu scripts/infra.nu plan staging`).

### Talos Linux Automation

- Talos configuration is generated via `talos_machine_configuration` data sources.
- Machine configs are uploaded to Proxmox as snippets (content_type: snippets).
- VM user_data references snippet IDs for immutable configurations.
- Bootstrap is automated via `talos_machine_bootstrap` resource.
- Kubeconfig and Talosconfig are retrieved via `talos_cluster_kubeconfig`.

## Packer Image Building

Purpose: create immutable VM templates for Proxmox infrastructure.

Rules:
- All templates must be built from Packer configurations in `infra/packer/`.
- Use Talos Image Factory for image sources (no manual ISO downloads).
- Template VM ID is parameterized (default: 2000) via `proxmox_template_vm_id`.
- Storage location is parameterized via `proxmox_storage_pool`.
- Templates must be rebuilt when upgrading Talos versions.

Prohibited: manual VM template creation, editing templates via Proxmox UI, multiple template versions.

### Packer Guidelines

- Variables are defined in `variables.pkr.hcl`.
- Sensitive values use `vars.auto.pkrvars.hcl` (gitignored).
- Use `nu scripts/infra.nu build-template` for standardized builds.
- HCloud packer is deprecated; use Talos Image Factory directly.

## Git Commits

All commits must:
- Be made after file changes are complete.
- Include a descriptive commit message.
- Contain production-ready code only (no TODOs or commented debugging code).

## Agent Responsibilities

Agents working in this repository must:
- Preserve the cattle mindset for all infrastructure components.
- Maintain idempotency across bootstrap, orchestration, and IaC operations.
- Make environment changes via Dockerfiles for toolboxes, Packer for templates, Terraform for infrastructure.
- Commit all changes with descriptive messages.
- Ensure containers, VMs, and clusters can be destroyed and recreated reliably.
- Follow environment isolation: staging (HCloud) for testing, prod (Proxmox) for production.
- Use Nushell scripts (`nu scripts/infra.nu`, `nu scripts/cluster.nu`) for standardized operations.
- Never commit sensitive files: `*.tfvars`, `kubeconfig`, `talosconfig`, `vars.auto.pkrvars.hcl`.
- Update README files when adding new components or changing architecture.

