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
- Install only base dependencies: `podman`, `toolbox`, `nushell`, `git`, `curl`, `make`, `wget`.
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

## Agent Responsibilities

Agents working in this repository must preserve the cattle mindset, maintain idempotency, make environment changes via Dockerfiles, commit all changes, and ensure containers can be destroyed and recreated reliably.

