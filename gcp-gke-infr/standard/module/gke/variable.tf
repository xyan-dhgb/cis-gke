variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
}

variable "region" {
  description = "The region where the cluster will be created"
  type        = string
}

variable "zone" {
  description = "The zone where the cluster will be created"
  type        = string
}

variable "network_name" {
  description = "The name of the VPC network"
  type        = string
}

variable "subnet_name" {
  description = "The name of the subnet"
  type        = string
}

variable "cluster_secondary_range_name" {
  description = "The name of the secondary range for pods"
  type        = string
}

variable "services_secondary_range_name" {
  description = "The name of the secondary range for services"
  type        = string
}

variable "kubernetes_version" {
  description = "The Kubernetes version for the cluster"
  type        = string
}

variable "release_channel" {
  description = "The release channel for GKE cluster (RAPID, REGULAR, STABLE)"
  type        = string
}

variable "initial_node_count" {
  description = "The initial number of nodes in the cluster"
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

variable "auto_upgrade" {
  description = "Enable auto upgrade for nodes"
  type        = bool
}

variable "machine_type" {
  description = "The machine type for cluster nodes"
  type        = string
}

variable "disk_size_gb" {
  description = "Size of the disk attached to each node (in GB)"
  type        = number
}

variable "labels" {
  description = "Labels to apply to the cluster and nodes"
  type        = map(string)
}

variable "tags" {
  description = "Network tags to apply to nodes"
  type        = list(string)
}

variable "enable_http_load_balancing" {
  description = "Enable HTTP load balancing addon"
  type        = bool
}

variable "enable_network_policy_config" {
  description = "Enable network policy addon"
  type        = bool
}

variable "enable_gce_pd_csi_driver" {
  description = "Enable GCE Persistent Disk CSI Driver"
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

variable "enable_managed_prometheus" {
  description = "Enable managed Prometheus monitoring"
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
