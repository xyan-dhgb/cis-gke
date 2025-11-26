variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "cluster_name" {
  description = "GKE cluster name"
  type        = string
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