terraform {
  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = ">= 0.5.0"
    }
  }
}

locals {
  talos_endpoints = var.talos_endpoints != null ? var.talos_endpoints : var.controlplane_ips
}

resource "talos_machine_secrets" "this" {
  talos_version = var.talos_version
}

data "talos_machine_configuration" "controlplane" {
  cluster_name       = var.cluster_name
  cluster_endpoint   = var.cluster_endpoint
  machine_type       = "controlplane"
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version

  config_patches = var.config_patches_controlplane
}

data "talos_machine_configuration" "worker" {
  count = var.generate_worker_config && length(var.worker_ips) == 0 ? 1 : length(var.worker_ips)

  cluster_name       = var.cluster_name
  cluster_endpoint   = var.cluster_endpoint
  machine_type       = "worker"
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version

  config_patches = var.config_patches_worker
}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = local.talos_endpoints
  nodes                = local.talos_endpoints
}

resource "talos_machine_bootstrap" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoint             = var.controlplane_ips[0]
  node                 = var.controlplane_ips[0]
}

resource "talos_cluster_kubeconfig" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = var.controlplane_ips[0]

  depends_on = [
    talos_machine_bootstrap.this
  ]
}
