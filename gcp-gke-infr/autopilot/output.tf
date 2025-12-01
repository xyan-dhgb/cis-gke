output "cluster_name" {
  description = "The name of the GKE Autopilot cluster"
  value       = google_container_cluster.autopilot_cluster.name
}

output "endpoint" {
  description = "The IP address of the cluster master (sensitive)"
  value       = google_container_cluster.autopilot_cluster.endpoint
  sensitive   = true
}

output "ca_certificate" {
  description = "The cluster CA certificate for authentication (sensitive)"
  value       = google_container_cluster.autopilot_cluster.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "location" {
  description = "The location (region) of the cluster"
  value       = google_container_cluster.autopilot_cluster.location
}

output "master_version" {
  description = "The current Kubernetes version of the master"
  value       = google_container_cluster.autopilot_cluster.master_version
}