.PHONY: help build-toolboxes create-toolboxes enter-infra enter-cka enter-dev

REPO_DIR ?= $(HOME)/.infra-env
TOOLBOXES_DIR = $(REPO_DIR)/toolboxes

help:
	@echo "infra-env Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  make build-toolboxes   - Build all toolbox container images"
	@echo "  make create-toolboxes  - Create all toolboxes idempotently"
	@echo "  make enter-infra       - Enter the infra toolbox"
	@echo "  make enter-cka         - Enter the cka toolbox"
	@echo "  make enter-dev         - Enter the dev toolbox"

build-toolboxes:
	@echo "Building toolbox images..."
	podman build --file $(TOOLBOXES_DIR)/infra/Dockerfile --tag localhost/toolbox-infra:latest $(TOOLBOXES_DIR)/infra
	podman build --file $(TOOLBOXES_DIR)/cka/Dockerfile --tag localhost/toolbox-cka:latest $(TOOLBOXES_DIR)/cka
	podman build --file $(TOOLBOXES_DIR)/dev/Dockerfile --tag localhost/toolbox-dev:latest $(TOOLBOXES_DIR)/dev
	@echo "Toolbox images built successfully"

create-toolboxes: build-toolboxes
	@echo "Creating toolboxes..."
	toolbox create --container-name infra --image localhost/toolbox-infra:latest 2>/dev/null || echo "infra toolbox already exists"
	toolbox create --container-name cka --image localhost/toolbox-cka:latest 2>/dev/null || echo "cka toolbox already exists"
	toolbox create --container-name dev --image localhost/toolbox-dev:latest 2>/dev/null || echo "dev toolbox already exists"
	@echo "Toolboxes created successfully"

enter-infra:
	toolbox enter infra

enter-cka:
	toolbox enter cka

enter-dev:
	toolbox enter dev
