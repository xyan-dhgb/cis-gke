variable "project_id" {
  type = string
  description = "The ID of the project"
}

variable "region" {
  type = string
  description = "The region of the project"
}

variable "cluster_name" {
  type = string
  description = "Name of the cluster"
}

variable "network" {
  type = string
  description = "The network configuration of the cluster"
}

variable "subnetwork" {
  type = string
  description = "The subnetwork configuration of the cluster"
}

variable "released_channel" {
  type = string
  description = "Released channel of the cluster"
}