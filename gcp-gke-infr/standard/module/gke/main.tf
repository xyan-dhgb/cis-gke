resource "google_container_cluster" "gke_cluster" {
  name     = var.cluster_name
  project  = var.project_id
  location = var.zone

  # Cluster configuration
  network                  = var.network_name
  subnetwork               = var.subnet_name
  remove_default_node_pool = true
  initial_node_count       = var.initial_node_count

  # Kubernetes version and release channel
  release_channel {
    channel = var.release_channel
  }

  # IP Alias and VPC-native
  ip_allocation_policy {
    cluster_secondary_range_name  = var.cluster_secondary_range_name
    services_secondary_range_name = var.services_secondary_range_name
    cluster_ipv4_cidr_block       = null
    services_ipv4_cidr_block      = null
  }

  # Networking configuration
  addons_config {
    http_load_balancing {
      disabled = !var.enable_http_load_balancing
    }

    horizontal_pod_autoscaling {
      disabled = false
    }

    network_policy_config {
      disabled = !var.enable_network_policy_config
    }

    gce_persistent_disk_csi_driver_config {
      enabled = var.enable_gce_pd_csi_driver
    }
  }

  network_policy {
    enabled  = var.enable_network_policy
    provider = var.enable_network_policy ? "CALICO" : "PROVIDER_UNSPECIFIED"
  }

  # Dataplane V2
  datapath_provider = var.dataplane_v2_enabled ? "ADVANCED_DATAPATH" : "DATAPATH_PROVIDER_UNSPECIFIED"

  # Intranode visibility
  enable_intranode_visibility = var.intranode_visibility_enabled

  # Control plane authorization
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "0.0.0.0/0"
      display_name = "Allow all"
    }
  }

  # Logging and monitoring
  logging_config {
    enable_components = [
      "SYSTEM_COMPONENTS",
      "WORKLOADS"
    ]
  }

  monitoring_config {
    enable_components = [
      "SYSTEM_COMPONENTS"
    ]

    managed_prometheus {
      enabled = var.enable_managed_prometheus
    }
  }

  # Security
  enable_shielded_nodes = var.enable_shielded_nodes

  workload_identity_config {
    workload_pool = var.enable_workload_identity ? "${var.project_id}.svc.id.goog" : null
  }

  resource_labels = var.labels
}