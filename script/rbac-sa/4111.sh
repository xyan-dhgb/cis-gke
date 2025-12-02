#!/bin/bash

###############################################
# CIS 4.1.1 – Ensure cluster-admin is only used where required
###############################################

### ====== SETTINGS: ĐIỀN SẴN ====== ###
PROJECT_ID="cis-gcp-benchmark"
CLUSTER_NAME="cis-standard-cluster-v2"
CLUSTER_LOCATION="asia-southeast1-a"
### ================================== ###

echo ""
echo "========== GKE CIS 4.1.1 Automation (Non-Interactive) =========="
echo "Project ID      : $PROJECT_ID"
echo "Cluster Name    : $CLUSTER_NAME"
echo "Cluster Location: $CLUSTER_LOCATION"
echo ""

echo ">>> Setting GCP project..."
gcloud config set project "$PROJECT_ID" >/dev/null

echo ">>> Getting GKE credentials..."
gcloud container clusters get-credentials "$CLUSTER_NAME" \
  --zone "$CLUSTER_LOCATION" \
  --project "$PROJECT_ID"

if [ $? -ne 0 ]; then
  echo "[ERROR] Cannot connect to GKE cluster. Check Project/Cluster/Location."
  exit 1
fi

echo ">>> Connected to context:"
kubectl config current-context
echo ""

echo "=== Step 1: Detect unauthorized cluster-admin bindings ==="

VIOLATIONS=$(kubectl get clusterrolebindings -o json \
  | jq -r '.items[] 
      | select(.roleRef.name=="cluster-admin") 
      | {name: .metadata.name, subjects: [.subjects[].name]} 
      | select(.subjects[] != "system:masters") 
      | .name'
)

if [ -z "$VIOLATIONS" ]; then
  echo "[PASS] No unauthorized cluster-admin bindings detected on cluster: $CLUSTER_NAME"
  exit 0
fi

echo "[FAIL] Unauthorized cluster-admin bindings found:"
echo "$VIOLATIONS"
echo ""

echo "=== Step 2: Auto-remediation ==="
for BIND in $VIOLATIONS; do
  echo "Deleting binding: $BIND"
  kubectl delete clusterrolebinding "$BIND"
done

echo ""
echo "=== Step 3: Re-checking ==="
kubectl get clusterrolebindings \
  -o=custom-columns=NAME:.metadata.name,ROLE:.roleRef.name,SUBJECT:.subjects[*].name

echo ""
echo "========== DONE =========="
echo "CIS 4.1.1 compliance restored for cluster:"
echo "Cluster: $CLUSTER_NAME"
echo "Project: $PROJECT_ID"
echo "Location: $CLUSTER_LOCATION"
