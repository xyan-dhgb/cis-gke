# Tạo VPC network mới
resource "google_compute_network" "gke_network" {
  name                    = var.network_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
  project                 = var.project_id

  description = "GKE Network for ${var.cluster_name}"
}

# Tạo subnet mới
resource "google_compute_subnetwork" "gke_subnet" {
  name          = var.subnet_name
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.gke_network.id
  project       = var.project_id

  secondary_ip_range {
    range_name    = var.pods_range_name
    ip_cidr_range = var.pods_range_cidr
  }

  secondary_ip_range {
    range_name    = var.services_range_name
    ip_cidr_range = var.services_range_cidr
  }

  private_ip_google_access = true

  depends_on = [google_compute_network.gke_network]
}

# Firewall rule cho phép internal communication
resource "google_compute_firewall" "gke_internal" {
  name    = "${var.cluster_name}-internal"
  network = google_compute_network.gke_network.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = [
    var.subnet_cidr,
    var.pods_range_cidr
  ]
  target_tags = ["gke-node", "${var.cluster_name}-node"]
}

# Firewall rule cho phép SSH từ internet (optional)
resource "google_compute_firewall" "gke_ssh" {
  name    = "${var.cluster_name}-ssh"
  network = google_compute_network.gke_network.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["gke-node", "${var.cluster_name}-node"]
}

# Firewall rule cho API server access
resource "google_compute_firewall" "gke_api_server" {
  name    = "${var.cluster_name}-api-server"
  network = google_compute_network.gke_network.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.cluster_name}-node"]
}

# Firewall rule cho HTTP/HTTPS
resource "google_compute_firewall" "gke_http_https" {
  name    = "${var.cluster_name}-http-https"
  network = google_compute_network.gke_network.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server", "https-server", "${var.cluster_name}-node"]
}