variable "project_id" {
  description = "GCP Project ID"
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

variable "node_pool_name" {
  description = "Node pool name"
  type        = string
}

variable "machine_type" {
  description = "Machine type for nodes"
  type        = string
  default     = "n2-standard-4"
}

variable "disk_size_gb" {
  description = "Disk size in GB"
  type        = number
  default     = 100
}

variable "disk_type" {
  description = "Disk type"
  type        = string
  default     = "pd-standard"
}

variable "initial_node_count" {
  description = "Initial number of nodes"
  type        = number
  default     = 3

  validation {
    condition     = var.initial_node_count > 0
    error_message = "Initial node count must be greater than 0."
  }
}

variable "min_node_count" {
  description = "Minimum number of nodes"
  type        = number
  default     = 1

  validation {
    condition     = var.min_node_count > 0
    error_message = "Minimum node count must be greater than 0."
  }
}

variable "max_node_count" {
  description = "Maximum number of nodes"
  type        = number
  default     = 10

  validation {
    condition     = var.max_node_count >= var.min_node_count
    error_message = "Maximum node count must be greater than or equal to minimum node count."
  }
}

variable "preemptible" {
  description = "Use preemptible nodes"
  type        = bool
  default     = false
}

variable "auto_repair" {
  description = "Enable auto repair"
  type        = bool
  default     = true
}

variable "auto_upgrade" {
  description = "Enable auto upgrade"
  type        = bool
  default     = true
}

variable "labels" {
  description = "Labels for nodes"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Network tags for nodes"
  type        = list(string)
  default     = []
}

variable "boot_disk_kms_key" {
  description = "KMS key for boot disk encryption"
  type        = string
  default     = null
}