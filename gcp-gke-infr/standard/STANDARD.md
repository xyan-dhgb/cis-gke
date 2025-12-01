# CREATE GOOGLE KUBERNETES ENGINE (GKE) BY USING TERRAFORM

## Overview

- This repository provides a Terraform-based Infrastructure-as-Code (IaC) solution for provisioning a Google Kubernetes Engine (GKE) cluster on Google Cloud Platform (GCP) with configurations aligned to the CIS (Center for Internet Security) Kubernetes Benchmark.

- The goal of this setup is to help teams deploy a secure, scalable, and standards-compliant Kubernetes environment by default—reducing misconfiguration risks and simplifying ongoing security posture management.

## Key features

- **CIS Benchmark Alignment**: Terraform modules are designed to follow recommended security controls from the CIS Kubernetes Benchmark, including restrictions on privileged workloads, secure default configurations, and hardened cluster settings.

- **Modular Infrastructure Structure**: The deployment is organized into reusable and maintainable Terraform modules, enabling teams to customize or extend components without breaking the core architecture.

- **GKE Cluster Provisioning**: Automates the creation of a production-ready GKE cluster with:

  - Secure node and control plane configurations
  - Private cluster options
  - Network segmentation and VPC best practices
  - Logging, monitoring, and audit configurations

- **Scalability & Flexibility**: Supports different node pool layouts, regional deployments, autoscaling options, and integration with organizational policies.

##  Folder Structure

- The Terraform configuration follows a modular architecture to keep the codebase clean, maintainable, and easy to extend. Below is the directory layout:

```
gcp-infr/
├── main.tf              # Root module: orchestrates all child modules
├── variable.tf          # Input variable definitions for the root module
├── output.tf            # Output values exposed from the root module
├── terraform.tfvars     # Default configuration values
├── module/
│   ├── vpc/             # VPC module: networking, subnets, routing, firewall rules
│   │   ├── main.tf
│   │   ├── variable.tf
│   │   └── output.tf
│   ├── gke/             # GKE module: GKE cluster configuration
│   │   ├── main.tf
│   │   ├── variable.tf
│   │   └── output.tf
│   └── node_pool/       # Node Pool module: worker nodes, autoscaling, machine types
│       ├── main.tf
│       ├── variable.tf
│       └── output.tf
└── README.md            # Documentation of the project
```

## Modules

### 1. VPC Module (`./module/vpc`)

- This module provisions the foundational networking layer for the GKE environment. It creates a dedicated VPC network along with subnets and secondary IP ranges required for cluster and node pool operations.

- **Resources:**
  - **VPC Network**: Creates an isolated virtual network to host the GKE cluster and related components.
  - **Subnet với CIDR block**: Configures a primary subnet with a predefined CIDR range.
  - **Secondary IP ranges for Pods and Services**: Allocates IP ranges for Pods and Services, ensuring proper IPAM behavior and compatibility with GKE’s VPC-native mode.

- **Outputs:**
  - VPC network name, ID.
  - Subnet details (name, CIDR ranges, region).
  - Secondary IP ranges for Pods and Services.

### 2. GKE Module (`./module/gke`)

- This module handles the deployment of the GKE control plane with hardened settings aligned to security best practices and CIS Benchmark recommendations. It also ensures observability components like logging and monitoring are enabled.

- **Resources:**
  - **Release Channel**: REGULAR (recommended for stability + timely updates)
  - **Shielded Nodes**: Protects against rootkit and boot-time tampering
  - **Dataplane V2**: Enhanced security and performance for networking
  - **Network Policy**: Enforces L3/L4 traffic controls for Pods
  - **Managed Prometheus**: Native GKE monitoring stack
  - **Cloud Logging & Monitoring**: End-to-end visibility for cluster behavior

- **Outputs:**
  - Cluster metadata (name, location, networking info).
  - Current Kubernetes version.

### 3. Node Pool Module (`./module/node_pool`)

- This module provisions worker nodes for the cluster with autoscaling, lifecycle management, and security-focused instance settings.

- **Resources Provided**
  - Autoscaling support (min/max size, surge upgrades)
  - Auto-repair & auto-upgrade for node reliability
  - Shielded VM instance configuration
  - Customizable machine types (general-purpose or high-CPU/memory)
  - Network tags and labels for routing, firewall rules, or workload grouping

- **Outputs:**
  - Node pool metadata
  - Instance group URLs
  - Autoscaling configuration

## Configuration

### Requirements

- Terraform >= 1.0
- Google Cloud Provider
- GCP Project with the following APIs enabled:
  - Compute Engine API
  - Kubernetes Engine API
  - Cloud Resource Manager API

### Key Variables

| Variable             | Description             | Default         |
| -------------------- | ----------------------- | --------------- |
| `project_id`         | GCP Project ID          | Required        |
| `region`             | GCP region              | Required        |
| `zone`               | GCP zone                | Required        |
| `cluster_name`       | GKE cluster name        | Required        |
| `network_name`       | VPC network name        | Required        |
| `subnet_cidr`        | Subnet CIDR block       | Required        |
| `machine_type`       | Node machine type       | `e2-medium` |
| `initial_node_count` | Initial number of nodes | `1`             |
| `min_node_count`     | Minimum number of nodes | `1`             |
| `max_node_count`     | Maximum number of nodes | `3`            |

- Full details can be found in `variables.tf`.

## Guide to apply

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Check the plan

```bash
terraform plan
```

### 3. Apply configuration

```bash
terraform apply
```

### 4. Connect to the cluster

- After a successful Terraform apply, use the output `kubectl_config_command`:

```bash
terraform output kubectl_config_command
```

- Alternatively, you can run the command directly:

```bash
gcloud container clusters get-credentials <cluster-name> --region <region> --project <project-id>
```

### 5. Delete  infrastructure

```bash
terraform destroy
```

## Outputs

After applying the Terraform configuration, the following outputs will be available:

### VPC Outputs

- **vpc_network_name**: VPC network name
- **vpc_subnet_name**: Subnet name
- **vpc_subnet_cidr**: Subnet CIDR block
- **vpc_pods_range_name**: Secondary range name for pods
- **vpc_services_range_name**: Secondary range name for services

### GKE Outputs

- **cluster_name**: GKE cluster name
- **kubernetes_version**: Kubernetes version
- **release_channel**: Release channel

### Node Pool Outputs

- **node_pool_name**: Node pool name
- **node_pool_node_count**: Current number of nodes
- **node_pool_autoscaling_config**: Autoscaling configuration
- **node_pool_node_config**: Node configuration

## Security Features

- Shielded Nodes enabled
- Secure Boot and Integrity Monitoring
- Auto-repair and auto-upgrade for nodes
- Network policy support
- Dataplane V2 (eBPF-based)
- Private Google Access
- Boot disk encryption (optional KMS)
- Minimal OAuth scopes

## Monitoring and Logging

- Cloud Logging integration
- Cloud Monitoring integration
- Managed Prometheus (optional)
- GKE metrics và logs

## Customization

- To customize the configuration, edit the `terraform.tfvars` file:

```terraform
# Change machine type
machine_type = "e2-medium"

# Adjust autoscaling
min_node_count = 2
max_node_count = 20

# Add labels
labels = {
  "environment" = "production"
  "team"        = "platform"
}
```

## Dependencies

- The modules have the following dependencies:
   - The `gke` module depends on the `vpc` module
   - The `node_pool` module depends on the `gke` module

- Terraform will automatically handle the deployment order.

## Troubleshooting

### API Not Enabled

```bash
gcloud services enable compute.googleapis.com
gcloud services enable container.googleapis.com
```

### Quota Issues

- Check project quotas:

```bash
gcloud compute project-info describe --project=<project-id>
```

### Permissions Issues

Ensure the service account has the following roles:

- `roles/compute.admin`
- `roles/container.admin`
- `roles/iam.serviceAccountUser`
