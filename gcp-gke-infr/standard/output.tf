# VPC Outputs
output "vpc_network_name" {
  description = "VPC network name"
  value       = module.vpc.network_name
}

output "vpc_network_id" {
  description = "VPC network ID"
  value       = module.vpc.network_id
}

output "vpc_network_self_link" {
  description = "VPC network self link"
  value       = module.vpc.network_self_link
}

output "vpc_subnet_name" {
  description = "Subnet name"
  value       = module.vpc.subnet_name
}

output "vpc_subnet_id" {
  description = "Subnet ID"
  value       = module.vpc.subnet_id
}

output "vpc_subnet_cidr" {
  description = "Subnet CIDR block"
  value       = module.vpc.subnet_cidr
}

output "vpc_pods_range_name" {
  description = "Pod range name"
  value       = module.vpc.pods_range_name
}

output "vpc_pods_range_cidr" {
  description = "Pod range CIDR block"
  value       = module.vpc.pods_range_cidr
}

output "vpc_services_range_name" {
  description = "Services range name"
  value       = module.vpc.services_range_name
}

output "vpc_services_range_cidr" {
  description = "Services range CIDR block"
  value       = module.vpc.services_range_cidr
}

# GKE Cluster Outputs
output "cluster_name" {
  description = "GKE cluster name"
  value       = module.gke.cluster_name
}

output "cluster_id" {
  description = "GKE cluster ID"
  value       = module.gke.cluster_id
}

output "cluster_endpoint" {
  description = "GKE cluster endpoint"
  value       = module.gke.cluster_endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Cluster CA certificate"
  value       = module.gke.cluster_ca_certificate
  sensitive   = true
}

output "cluster_region" {
  description = "GCP region"
  value       = module.gke.region
}

output "cluster_zone" {
  description = "GCP zone"
  value       = module.gke.zone
}

output "kubernetes_version" {
  description = "Kubernetes version"
  value       = module.gke.kubernetes_version
}

output "release_channel" {
  description = "Release channel"
  value       = module.gke.release_channel
}

output "cluster_network_name" {
  description = "Network name"
  value       = module.gke.network_name
}

output "cluster_subnetwork_name" {
  description = "Subnetwork name"
  value       = module.gke.subnetwork_name
}

# Node Pool Outputs
output "node_pool_name" {
  description = "Name of the node pool"
  value       = module.node_pool.node_pool_name
}

output "node_pool_id" {
  description = "ID of the node pool"
  value       = module.node_pool.node_pool_id
}

output "node_pool_instance_group_urls" {
  description = "List of instance group URLs"
  value       = module.node_pool.instance_group_urls
}

output "node_pool_managed_instance_group_urls" {
  description = "List of managed instance group URLs"
  value       = module.node_pool.managed_instance_group_urls
}

output "node_pool_node_count" {
  description = "Current number of nodes in the node pool"
  value       = module.node_pool.node_count
}

output "node_pool_autoscaling_config" {
  description = "Autoscaling configuration for the node pool"
  value       = module.node_pool.autoscaling_config
}

output "node_pool_node_config" {
  description = "Node configuration details"
  value       = module.node_pool.node_config
}

output "node_pool_management_config" {
  description = "Management configuration for the node pool"
  value       = module.node_pool.management_config
}

# Kubectl Configuration Command
output "kubectl_config_command" {
  description = "Command to configure kubectl"
  value       = "gcloud container clusters get-credentials ${module.gke.cluster_name} --region ${module.gke.region} --project ${var.project_id}"
}
