locals {
  cluster_endpoint = "https://${module.hcloud_nodes.load_balancer_ip}:6443"
}

module "hcloud_nodes" {
  source = "../../modules/hcloud-nodes"

  cluster_name          = var.cluster_name
  talos_image_id        = var.talos_image_id
  controlplane_type     = var.cp_server_type
  controlplane_location = var.hcloud_location
  workers               = var.workers
  talos_version         = var.talos_version

  controlplane_user_data = module.talos_cluster.machine_configuration_controlplane
  worker_user_data       = module.talos_cluster.machine_configuration_worker[0]
  cluster_endpoint       = local.cluster_endpoint
}

module "talos_cluster" {
  source = "../../modules/talos-cluster"

  cluster_name     = var.cluster_name
  cluster_endpoint = local.cluster_endpoint
  talos_version    = var.talos_version
  controlplane_ips = module.hcloud_nodes.controlplane_ips
  worker_ips       = []

  config_patches_controlplane = [
    file("${path.module}/../../../talos/patches/providers/hcloud.yaml")
  ]
  config_patches_worker = [
    file("${path.module}/../../../talos/patches/providers/hcloud.yaml")
  ]
}
