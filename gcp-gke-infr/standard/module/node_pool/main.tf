resource "google_container_node_pool" "primary" {
  name           = var.node_pool_name
  cluster        = var.cluster_name
  project        = var.project_id
  location       = var.zone
  node_count     = var.initial_node_count
  
  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }

  management {
    auto_repair  = var.auto_repair
    auto_upgrade = var.auto_upgrade
  }

  node_config {
    machine_type = var.machine_type
    disk_size_gb = var.disk_size_gb
    disk_type    = var.disk_type
    preemptible  = var.preemptible

    # OAuth scopes for node access
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append",
    ]

    # GKE metadata
    metadata = {
      disable-legacy-endpoints = "true"
    }

    # Shielded instances
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    # Labels and network tags
    labels = var.labels
    tags   = concat(["gke-node"], var.tags)

    # Image type
    image_type = "COS_CONTAINERD"

    # Boot disk encryption
    boot_disk_kms_key = var.boot_disk_kms_key
  }

  lifecycle {
    create_before_destroy = true
  }
}