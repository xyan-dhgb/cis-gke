output "network_name" {
  description = "VPC network name"
  value       = google_compute_network.gke_network.name
}

output "network_id" {
  description = "VPC network ID"
  value       = google_compute_network.gke_network.id
}

output "network_self_link" {
  description = "VPC network self link"
  value       = google_compute_network.gke_network.self_link
}

output "subnet_name" {
  description = "Subnet name"
  value       = google_compute_subnetwork.gke_subnet.name
}

output "subnet_id" {
  description = "Subnet ID"
  value       = google_compute_subnetwork.gke_subnet.id
}

output "subnet_cidr" {
  description = "Subnet CIDR block"
  value       = google_compute_subnetwork.gke_subnet.ip_cidr_range
}

output "pods_range_name" {
  description = "Pod range name"
  value       = var.pods_range_name
}

output "pods_range_cidr" {
  description = "Pod range CIDR block"
  value       = var.pods_range_cidr
}

output "services_range_name" {
  description = "Services range name"
  value       = var.services_range_name
}

output "services_range_cidr" {
  description = "Services range CIDR block"
  value       = var.services_range_cidr
}