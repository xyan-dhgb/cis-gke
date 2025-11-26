project_id  = "YOUR_PROJECT-ID"
region      = "YOUR_REGION"
zone        = "YOUR_ZONE"
cluster_name = "YOUR_CLUSTER_NAME"

# Network configuration
network_name         = "gke-network-v2"
subnet_name          = "gke-subnet-v2"
subnet_cidr          = "10.0.0.0/20"
pods_range_name      = "gke-pods-v2"
pods_range_cidr      = "10.4.0.0/14"
services_range_name  = "gke-services-v2"
services_range_cidr  = "10.0.16.0/20"

# Kubernetes configuration
kubernetes_version   = "1.33.5-gke.1201000"
release_channel      = "REGULAR"
auto_upgrade         = true

# Networking features
enable_ip_alias              = true
enable_network_policy        = false
dataplane_v2_enabled         = true
intranode_visibility_enabled = true
enable_http_load_balancing   = true

# Security features
enable_shielded_nodes           = true
enable_workload_identity        = false
enable_network_policy_config    = false
boot_disk_kms_key               = null

# Monitoring and logging
logging_service       = "logging.googleapis.com/kubernetes"
monitoring_service    = "monitoring.googleapis.com/kubernetes"
enable_managed_prometheus = true

# Node pool configuration
node_pool_name      = "primary-node-pool"
machine_type        = "e2-medium"
disk_size_gb        = 12
disk_type           = "pd-standard"
initial_node_count  = 1
min_node_count      = 1
max_node_count      = 3
preemptible         = false
auto_repair         = true

# Storage drivers
enable_gce_pd_csi_driver = true

# Labels and tags
labels = {
  "managed-by"  = "terraform"
  "cluster"     = "cis-standard-v2"
  "version"     = "2"
}

tags = []