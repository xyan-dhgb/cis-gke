# VPC Module
module "vpc" {
  source = "./module/vpc"

  project_id           = var.project_id
  region               = var.region
  cluster_name         = var.cluster_name
  network_name         = var.network_name
  subnet_name          = var.subnet_name
  subnet_cidr          = var.subnet_cidr
  pods_range_name      = var.pods_range_name
  pods_range_cidr      = var.pods_range_cidr
  services_range_name  = var.services_range_name
  services_range_cidr  = var.services_range_cidr
}

# GKE Cluster Module
module "gke" {
  source = "./module/gke"
  project_id                      = var.project_id
  cluster_name                    = var.cluster_name
  region                          = var.region
  zone                            = var.zone
  network_name                    = module.vpc.network_name
  subnet_name                     = module.vpc.subnet_name
  cluster_secondary_range_name    = module.vpc.pods_range_name
  services_secondary_range_name   = module.vpc.services_range_name
  kubernetes_version              = var.kubernetes_version
  release_channel                 = var.release_channel
  initial_node_count              = var.initial_node_count
  min_node_count                  = var.min_node_count
  max_node_count                  = var.max_node_count
  auto_upgrade                    = var.auto_upgrade
  machine_type                    = var.machine_type
  disk_size_gb                    = var.disk_size_gb
  labels                          = var.labels
  tags                            = var.tags
  enable_http_load_balancing      = var.enable_http_load_balancing
  enable_network_policy_config    = var.enable_network_policy_config
  enable_gce_pd_csi_driver        = var.enable_gce_pd_csi_driver
  enable_network_policy           = var.enable_network_policy
  dataplane_v2_enabled            = var.dataplane_v2_enabled
  intranode_visibility_enabled    = var.intranode_visibility_enabled
  enable_managed_prometheus       = var.enable_managed_prometheus
  enable_shielded_nodes           = var.enable_shielded_nodes
  enable_workload_identity        = var.enable_workload_identity
}

# Node Pool Module
module "node_pool" {
  source = "./module/node_pool"

  project_id         = var.project_id
  zone               = var.zone
  cluster_name       = module.gke.cluster_name
  node_pool_name     = var.node_pool_name
  machine_type       = var.machine_type
  disk_size_gb       = var.disk_size_gb
  disk_type          = var.disk_type
  initial_node_count = var.initial_node_count
  min_node_count     = var.min_node_count
  max_node_count     = var.max_node_count
  preemptible        = var.preemptible
  auto_repair        = var.auto_repair
  auto_upgrade       = var.auto_upgrade
  labels             = var.labels
  tags               = var.tags
  boot_disk_kms_key  = var.boot_disk_kms_key

  depends_on = [module.gke]
}