#!/bin/bash
# Automated CIS Benchmark Check: VPC Flow Logs + Intra-node Visibility
# Works for zonal/regional clusters where subnet region may differ from cluster zone

CLUSTER_NAME=$1
PROJECT_ID=$(gcloud config get-value project)

if [[ -z "$CLUSTER_NAME" ]]; then
    echo "Usage: $0 <cluster-name>"
    exit 1
fi

echo "=== CIS-BENCHMARK CHECK: VPC Flow Logs & Intra-node Visibility ==="
echo ""

# --- Detect cluster location ---
CLUSTER_INFO=$(gcloud container clusters list --project "$PROJECT_ID" --filter="name=$CLUSTER_NAME" --format="value(location,locationType)")

if [[ -z "$CLUSTER_INFO" ]]; then
    echo "ERROR: Cluster $CLUSTER_NAME not found in project $PROJECT_ID"
    exit 1
fi

CLUSTER_LOCATION=$(echo "$CLUSTER_INFO" | awk '{print $1}')
CLUSTER_TYPE=$(echo "$CLUSTER_INFO" | awk '{print $2}')

if [[ "$CLUSTER_TYPE" == "ZONE" ]]; then
    LOCATION_FLAG="--zone $CLUSTER_LOCATION"
    echo "Detected Zonal Cluster: $CLUSTER_LOCATION"
else
    LOCATION_FLAG="--region $CLUSTER_LOCATION"
    echo "Detected Regional Cluster: $CLUSTER_LOCATION"
fi

echo ""
echo "â†’ Fetching cluster subnetwork..."

SUBNET=$(gcloud container clusters describe "$CLUSTER_NAME" $LOCATION_FLAG \
    --format="value(networkConfig.subnetwork)")

if [[ -z "$SUBNET" ]]; then
    echo "ERROR: Could not determine subnetwork for cluster $CLUSTER_NAME"
    exit 1
fi

echo "Cluster subnetwork: $SUBNET"

# --- Extract region from subnet selfLink ---
SUBNET_REGION=$(echo "$SUBNET" | awk -F'/' '{print $(NF-1)}')
echo "Subnet region: $SUBNET_REGION"

echo ""
echo "=== Checking VPC Flow Logs ==="
FLOW_LOGS=$(gcloud compute networks subnets describe "$SUBNET" \
    --region "$SUBNET_REGION" \
    --format="value(logConfig.enable)")

if [[ "$FLOW_LOGS" == "True" ]]; then
    echo "PASS: VPC Flow Logs is ENABLED âœ…"
else
    echo "FAIL: VPC Flow Logs is DISABLED âŒ"
fi

echo ""
echo "=== Checking Intra-node Visibility ==="
INTRA_NODE=$(gcloud container clusters describe "$CLUSTER_NAME" $LOCATION_FLAG \
    --format="value(networkConfig.enableIntraNodeVisibility)")

if [[ "$INTRA_NODE" == "True" ]]; then
    echo "PASS: Intra-node visibility is ENABLED âœ…"
else
    echo "FAIL: Intra-node visibility is DISABLED âœ…"
fi

echo ""
echo "=== Completed ==="