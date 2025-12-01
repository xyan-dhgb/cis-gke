resource "google_container_cluster" "autopilot_cluster" {
  name = var.cluster_name
  location = var.region
  enable_autopilot = true
  
  # Network
  network = var.network
  subnetwork = var.subnetwork

  # Released channel
  release_channel {
    channel = var.released_channel
  }

  # Workload Identity to connect with GCP IAM
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }


  # IP allias (VPC-native)
  # Autopilot will set IP for Pod and Service
  ip_allocation_policy {}

  # Deletion protection - set to false for easier testing
  deletion_protection = false

  # Private cluster - Don't need external IP for nodes for better Quota saving
  private_cluster_config {
    enable_private_nodes    = true   # Nodes use private IP only (save quota)
    enable_private_endpoint = false  # Control plane still accessible from internet (easy access)
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }
}