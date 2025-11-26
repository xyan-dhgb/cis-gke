variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "zone" {
  description = "GCP zone"
  type        = string
}

variable "cluster_name" {
  description = "GKE cluster name"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the cluster"
  type        = string
}

variable "release_channel" {
  description = "Release channel for GKE cluster (RAPID, REGULAR, STABLE)"
  type        = string
}

variable "auto_upgrade" {
  description = "Enable auto upgrade for nodes"
  type        = bool
}

variable "network_name" {
  description = "VPC network name"
  type        = string
}

variable "subnet_name" {
  description = "Subnet name"
  type        = string
}

variable "subnet_cidr" {
  description = "Subnet CIDR block"
  type        = string
}

variable "pods_range_name" {
  description = "Pod range name"
  type        = string
}

variable "pods_range_cidr" {
  description = "Pod range CIDR block"
  type        = string
}

variable "services_range_name" {
  description = "Services range name"
  type        = string
}

variable "services_range_cidr" {
  description = "Services range CIDR block"
  type        = string
}

variable "node_pool_name" {
  description = "Node pool name"
  type        = string
}

variable "machine_type" {
  description = "Machine type for nodes"
  type        = string
}

variable "disk_size_gb" {
  description = "Disk size in GB"
  type        = number
}

variable "disk_type" {
  description = "Disk type"
  type        = string
}

variable "initial_node_count" {
  description = "Initial number of nodes"
  type        = number
}

variable "min_node_count" {
  description = "Minimum number of nodes for autoscaling"
  type        = number
}

variable "max_node_count" {
  description = "Maximum number of nodes for autoscaling"
  type        = number
}

variable "preemptible" {
  description = "Use preemptible nodes"
  type        = bool
}

variable "auto_repair" {
  description = "Enable auto repair"
  type        = bool
}

variable "enable_ip_alias" {
  description = "Enable IP alias for VPC"
  type        = bool
}

variable "enable_network_policy" {
  description = "Enable network policy for the cluster"
  type        = bool
}

variable "dataplane_v2_enabled" {
  description = "Enable Dataplane V2 (advanced networking)"
  type        = bool
}

variable "intranode_visibility_enabled" {
  description = "Enable intranode visibility"
  type        = bool
}

variable "enable_http_load_balancing" {
  description = "Enable HTTP load balancing addon"
  type        = bool
}

variable "enable_network_policy_config" {
  description = "Enable network policy addon"
  type        = bool
}

variable "enable_shielded_nodes" {
  description = "Enable shielded nodes feature"
  type        = bool
}

variable "enable_workload_identity" {
  description = "Enable Workload Identity for the cluster"
  type        = bool
}

variable "boot_disk_kms_key" {
  description = "KMS key for boot disk encryption"
  type        = string
}

variable "logging_service" {
  description = "The logging service to use"
  type        = string
}

variable "monitoring_service" {
  description = "The monitoring service to use"
  type        = string
}

variable "enable_managed_prometheus" {
  description = "Enable managed Prometheus monitoring"
  type        = bool
}

variable "enable_gce_pd_csi_driver" {
  description = "Enable GCE Persistent Disk CSI Driver"
  type        = bool
}

variable "labels" {
  description = "Labels to apply to the cluster and nodes"
  type        = map(string)
}

variable "tags" {
  description = "Network tags to apply to nodes"
  type        = list(string)
}