output "cluster_name" {
  description = "GKE cluster name"
  value       = google_container_cluster.gke_cluster.name
}

output "cluster_id" {
  description = "GKE cluster ID"
  value       = google_container_cluster.gke_cluster.id
}

output "cluster_endpoint" {
  description = "GKE cluster endpoint"
  value       = google_container_cluster.gke_cluster.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Cluster CA certificate"
  value       = google_container_cluster.gke_cluster.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "region" {
  description = "GCP region"
  value       = var.region
}

output "zone" {
  description = "GCP zone"
  value       = google_container_cluster.gke_cluster.location
}

output "kubernetes_version" {
  description = "Kubernetes version"
  value       = google_container_cluster.gke_cluster.min_master_version
}

output "release_channel" {
  description = "Release channel"
  value       = google_container_cluster.gke_cluster.release_channel[0].channel
}

output "network_name" {
  description = "Network name"
  value       = google_container_cluster.gke_cluster.network
}

output "subnetwork_name" {
  description = "Subnetwork name"
  value       = google_container_cluster.gke_cluster.subnetwork
}