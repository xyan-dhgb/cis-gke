output "node_pool_name" {
  description = "Name of the node pool"
  value       = google_container_node_pool.primary.name
}

output "node_pool_id" {
  description = "ID of the node pool"
  value       = google_container_node_pool.primary.id
}

output "instance_group_urls" {
  description = "List of instance group URLs which have been assigned to this node pool"
  value       = google_container_node_pool.primary.instance_group_urls
}

output "managed_instance_group_urls" {
  description = "List of managed instance group URLs which have been assigned to this node pool"
  value       = google_container_node_pool.primary.managed_instance_group_urls
}

output "node_count" {
  description = "Current number of nodes in the node pool"
  value       = google_container_node_pool.primary.node_count
}

output "autoscaling_config" {
  description = "Autoscaling configuration for the node pool"
  value = {
    min_node_count = google_container_node_pool.primary.autoscaling[0].min_node_count
    max_node_count = google_container_node_pool.primary.autoscaling[0].max_node_count
  }
}

output "node_config" {
  description = "Node configuration details"
  value = {
    machine_type = google_container_node_pool.primary.node_config[0].machine_type
    disk_size_gb = google_container_node_pool.primary.node_config[0].disk_size_gb
    disk_type    = google_container_node_pool.primary.node_config[0].disk_type
    image_type   = google_container_node_pool.primary.node_config[0].image_type
    preemptible  = google_container_node_pool.primary.node_config[0].preemptible
  }
}

output "management_config" {
  description = "Management configuration for the node pool"
  value = {
    auto_repair  = google_container_node_pool.primary.management[0].auto_repair
    auto_upgrade = google_container_node_pool.primary.management[0].auto_upgrade
  }
}
