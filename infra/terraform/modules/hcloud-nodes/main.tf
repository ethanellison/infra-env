terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.45"
    }
    talos = {
      source  = "siderolabs/talos"
      version = ">= 0.5.0"
    }
  }
}

locals {
  cluster_endpoint = var.cluster_endpoint != "" ? var.cluster_endpoint : "https://${hcloud_load_balancer.controlplane.ipv4}:6443"
}

locals {
  talos_schematic_id = "ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515"
}

resource "hcloud_network" "network" {
  name     = var.network_name
  ip_range = var.network_ip_range
}

resource "hcloud_network_subnet" "subnet" {
  network_id   = hcloud_network.network.id
  type         = "cloud"
  network_zone = var.network_zone
  ip_range     = var.subnet_ip_range
}

resource "hcloud_load_balancer" "controlplane" {
  name               = "${var.cluster_name}-api"
  load_balancer_type = var.load_balancer_type
  network_zone       = var.network_zone

  labels = {
    cluster = var.cluster_name
    role    = "api-lb"
  }
}

resource "hcloud_load_balancer_network" "lb_network" {
  load_balancer_id = hcloud_load_balancer.controlplane.id
  network_id       = hcloud_network.network.id
}

resource "hcloud_load_balancer_service" "kubernetes_api" {
  load_balancer_id = hcloud_load_balancer.controlplane.id
  protocol         = "tcp"
  listen_port      = 6443
  destination_port = 6443

  health_check {
    protocol = "tcp"
    port     = 6443
    interval = 15
    timeout  = 10
    retries  = 3
  }
}

resource "hcloud_load_balancer_service" "talos_api" {
  load_balancer_id = hcloud_load_balancer.controlplane.id
  protocol         = "tcp"
  listen_port      = 50000
  destination_port = 50000

  health_check {
    protocol = "tcp"
    port     = 50000
    interval = 15
    timeout  = 10
    retries  = 3
  }
}

resource "hcloud_server" "controlplane" {
  name        = "${var.cluster_name}-cp-1"
  image       = var.talos_image_id
  server_type = var.controlplane_type
  location    = var.controlplane_location

  labels = {
    cluster = var.cluster_name
    role    = "controlplane"
  }

  user_data = var.controlplane_user_data

  network {
    network_id = hcloud_network.network.id
    ip         = var.controlplane_ip
  }

  depends_on = [
    hcloud_network_subnet.subnet,
    hcloud_load_balancer.controlplane
  ]
}

resource "hcloud_server" "worker" {
  for_each = var.workers

  name        = "${var.cluster_name}-${each.key}"
  image       = var.talos_image_id
  server_type = each.value.server_type
  location    = each.value.location

  labels = {
    cluster = var.cluster_name
    role    = "worker"
  }

  user_data = var.worker_user_data != "" ? var.worker_user_data : (length(var.workers) > 0 ? data.talos_machine_configuration.worker[0].machine_configuration : "")

  network {
    network_id = hcloud_network.network.id
  }

  depends_on = [
    hcloud_network_subnet.subnet,
    hcloud_load_balancer.controlplane,
    hcloud_server.controlplane
  ]
}

resource "hcloud_load_balancer_target" "controlplane" {
  type             = "server"
  load_balancer_id = hcloud_load_balancer.controlplane.id
  server_id        = hcloud_server.controlplane.id
  use_private_ip   = true

  depends_on = [
    hcloud_server.controlplane,
    hcloud_load_balancer_network.lb_network
  ]
}

resource "talos_machine_secrets" "workers" {
  count         = length(var.workers) > 0 ? 1 : 0
  talos_version = var.talos_version
}

data "talos_machine_configuration" "worker" {
  count = length(var.workers) > 0 && var.worker_user_data == "" ? 1 : 0

  cluster_name       = var.cluster_name
  cluster_endpoint   = local.cluster_endpoint
  machine_type       = "worker"
  machine_secrets    = talos_machine_secrets.workers[0].machine_secrets
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version

  config_patches = []
}
