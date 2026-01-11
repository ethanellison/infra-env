#!/bin/bash
set -euo pipefail

readonly PACKAGES=(podman toolbox nushell git curl make wget nvim)

die() {
    echo "ERROR: $*" >&2
    exit 1
}

check_reboot_required() {
    if [ -f /run/reboot-required ]; then
        die "System reboot required. Please reboot and re-run this script."
    fi
}

install_packages() {
    echo "Installing required packages: ${PACKAGES[*]}"
    rpm-ostree install --assume-yes "${PACKAGES[@]}" || die "Failed to install packages"
    check_reboot_required
}

# Main bootstrap sequence
main() {
    echo "=== Phase 0: System Bootstrap ==="
    check_reboot_required
    install_packages
    echo "Transferring control to bootstrap/bootstrap.nu"
    "${REPO_DIR}/bootstrap/bootstrap.nu" || die "Nushell bootstrap failed"
    exit 0
}

main "$@"
