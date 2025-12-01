# GKE Autopilot Infrastructure

## Overview

- This Terraform configuration deploys a **Google Kubernetes Engine (GKE) Autopilot cluster** with security best practices and cost optimization features.

### What is GKE Autopilot?

- GKE Autopilot is a fully managed Kubernetes service where Google manages:
    - **Node provisioning and scaling**: Automatically creates/removes nodes based on workload
    - **Node configuration**: Optimizes node machine types and settings
    - **Security patches**: Automatically applies security updates
    - **Resource optimization**: Right-sizes nodes to minimize costs

### Key Features

-  **Private Nodes**: Nodes have no external IP (saves quota and improves security)  
-  **Workload Identity**: Secure authentication with GCP services  
-  **VPC-Native Networking**: Pod IP addresses from VPC subnet  
-  **Auto-scaling**: Nodes scale from 0 based on workload demand  
-  **Secure by Default**: Shielded nodes, binary authorization ready

## Folder Structure

```
gcp-gke-infr/autopilot/
├── backend.tf         # Remote state configuration (GCS)
├── main.tf            # GKE Autopilot cluster resource
├── provider.tf        # Terraform and Google provider config
├── terraform.tfvars   # Variable values (customize this)
├── variable.tf        # Input variable definitions
└── output.tf          # Output values after deployment
```

## Prerequisites

### Required Tools
```bash
# Terraform >= 1.5.0
terraform version

# gcloud CLI
gcloud version

# kubectl
kubectl version --client
```

### GCP Permissions
- Your account needs these IAM roles:
    - `roles/container.admin` - Create and manage GKE clusters
    - `roles/compute.networkAdmin` - Manage VPC resources
    - `roles/iam.serviceAccountUser` - Use service accounts

### Required APIs
```bash
gcloud services enable container.googleapis.com
gcloud services enable compute.googleapis.com
```

## Deployment Guide

### Step 1: Configure Variables

- Edit `terraform.tfvars`:
```hcl
project_id       = "your-gcp-project-id"
region           = "asia-southeast1"
cluster_name     = "autopilot-cluster"
network          = "default"
subnetwork       = null
released_channel = "REGULAR"
```

### Step 2: Initialize Terraform

```bash
cd gcp-gke-infr/autopilot
terraform init
```

- This will:
    - Download Google provider plugin
    - Configure remote state backend (GCS)

### Step 3: Review Plan

```bash
terraform plan
```

- Expected resources:
    - 1 GKE Autopilot cluster
    - Auto-managed node pools
    - VPC-native IP ranges

### Step 4: Deploy

- **Deployment time**: ~7-10 minutes

```bash
terraform apply -auto-approve
```

### Step 5: Verify Deployment

```bash
# View outputs
terraform output

# Get cluster credentials
gcloud container clusters get-credentials YOUR_CLUSTER_NAME --region YOUR_REGION  --project YOUR_PROJECT_ID

# Check cluster status
kubectl get nodes
kubectl get pods -A
```

## Post-Deployment

### Connect to Cluster

```bash
# Configure kubectl
gcloud container clusters get-credentials  YOUR_CLUSTER_NAME --region YOUR_REGION  --project YOUR_PROJECT_ID

# Verify connection
kubectl cluster-info
kubectl get nodes -o wide
```

### Deploy Sample Workload

```bash
# Create a test pod
kubectl run nginx-test --image=nginx:alpine

# Wait for node provisioning (30-90 seconds)
kubectl get pods -w

# Check node was created
kubectl get nodes
```

### View Cluster Details

```bash
# Cluster info
gcloud container clusters describe  YOUR_CLUSTER_NAME --region YOUR_REGION  --project YOUR_PROJECT_ID

# List node pools (auto-managed)
gcloud container node-pools list --cluster=YOUR_CLUSTER_NAME --region= YOUR_REGION
```

---

## Features & Best Practices

### Autopilot Auto-Scaling

**Behavior**:
- Nodes scale automatically
- Creates nodes when pods are pending
- Removes idle nodes after ~10 minutes
- This is **normal behavior**, not a bug!
- Example:

```bash
# No workload = 0 nodes
kubectl get nodes
# No resources found

# Deploy workload
kubectl create deployment nginx --image=nginx --replicas=3

# Wait 30-90 seconds, nodes auto-created
kubectl get nodes
# NAME                                  STATUS   AGE
# gk3-autopilot-cluster-pool-1-abc123   Ready    45s
```

### Workload Identity Usage

```yaml
# 1. Create GCP Service Account
gcloud iam service-accounts create my-app-sa

# 2. Grant GCP permissions
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:my-app-sa@PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/storage.objectViewer"

# 3. Bind to Kubernetes Service Account
gcloud iam service-accounts add-iam-policy-binding \
  my-app-sa@PROJECT_ID.iam.gserviceaccount.com \
  --role roles/iam.workloadIdentityUser \
  --member "serviceAccount:PROJECT_ID.svc.id.goog[NAMESPACE/KSA_NAME]"

# 4. Annotate K8s Service Account
kubectl annotate serviceaccount KSA_NAME \
  iam.gke.io/gcp-service-account=my-app-sa@PROJECT_ID.iam.gserviceaccount.com
```

### Update Strategy

```bash
# Check kubectl client version
kubectl version --client

# Check both client and server version
kubectl version

# Autopilot auto-updates based on release channel:
# - RAPID: ~1-2 weeks after new K8s version
# - REGULAR: ~2-3 months (recommended)
# - STABLE: ~2-4 months

# View cluster version
gcloud container clusters describe YOUR_CLUSTER_NAME --region YOUR_REGION --format="value(currentMasterVersion)"
```

---

## Troubleshooting

### Issue: "No resources found" for nodes

- **Cause**: Autopilot scaled nodes to 0 (no workload)
- **Solution**: Deploy a pod, nodes will auto-create in 30-90 seconds
```bash
kubectl run test --image=nginx
kubectl get pods -w  # Wait for Running status
kubectl get nodes    # Nodes appear
```

### Issue: Pods stuck in Pending

- **Cause**: Missing resource requests
- **Solution**: Add resource requests to pod spec
```yaml
resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
```

### Issue: Cannot connect to cluster

- **Solution**: Get fresh credentials
```bash
gcloud container clusters get-credentials YOUR_CLUSTER_NAME --region YOUR_REGION --project YOUR_PROJECT_ID
```

### Issue: Quota exceeded

- **Cause**: Too many external IPs in region
- **Solution**: This config uses **private nodes** (0 external IPs per node)

## Cleanup

### Destroy Infrastructure

```bash
# Delete cluster and all resources
terraform destroy -auto-approve
```

- **Warning**: This will delete:
    - GKE cluster
    - All deployed workloads
    - Auto-created resources (node pools, IPs)

### Manual Cleanup (if needed)

```bash
# Delete cluster via gcloud
gcloud container clusters delete YOUR_CLUSTER_NAME --region YOUR_REGION --quiet
```

---

## Comparison: Autopilot vs Standard

| Feature | Standard GKE | Autopilot GKE |
|---------|-------------|---------------|
| **Node Management** | Manual | Automatic |
| **Node Scaling** | Configure autoscaler | Fully automatic |
| **Node Sizing** | Choose machine type | Google optimizes |
| **Security Patches** | Manual apply | Automatic |
| **Pricing** | Pay for nodes (even if idle) | Pay for pod resources |
| **Flexibility** | Full control | Some restrictions |
| **Complexity** | Higher | Lower |
| **Best For** | Custom requirements | Most workloads |

### Useful Commands
```bash
# View cluster details
gcloud container clusters describe CLUSTER_NAME --region REGION

# View autopilot configuration
kubectl get configmap cluster-autoscaler-status -n kube-system -o yaml

# Check pod resource usage
kubectl top pods -A

# View cluster events
kubectl get events --all-namespaces --sort-by='.lastTimestamp'

# Export cluster config
gcloud container clusters get-credentials CLUSTER_NAME --region REGION
```