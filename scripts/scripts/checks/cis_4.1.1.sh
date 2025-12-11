#!/bin/bash

###############################################
# CIS 4.1.1 – Ensure cluster-admin is only used where required
###############################################

# YÊU CẦU:
# - Biến PROJECT_ID, CLUSTER_NAME, ZONE được export từ main.sh
# - main.sh đã chạy get-credentials trước khi chạy file này

# Kiểm tra biến môi trường
if [ -z "$PROJECT_ID" ] || [ -z "$CLUSTER_NAME" ] || [ -z "$ZONE" ]; then
  echo "[ERROR] Missing required environment variables!"
  echo "PROJECT_ID=$PROJECT_ID"
  echo "CLUSTER_NAME=$CLUSTER_NAME"
  echo "ZONE=$ZONE"
  exit 1
fi

echo ""
echo "========== GKE CIS 4.1.1 Automation =========="

echo ">>> Using existing kubectl context:"
kubectl config current-context
echo ""

# ======================= CONFIRM YES/NO ==========================
echo "⚠️  This script will SCAN unauthorized cluster-admin bindings."
read -p "Do you want to continue? (yes/no): " CONFIRM

if [[ "$CONFIRM" != "yes" ]]; then
    echo "❌ Action cancelled."
    exit 0
fi

echo "✔️ Confirmation received. Running script..."
echo ""
# ===============================================================

echo "=== Step 1: Detect unauthorized cluster-admin bindings ==="

VIOLATIONS=$(kubectl get clusterrolebindings -o json \
  | jq -r '.items[] 
      | select(.roleRef.name=="cluster-admin") 
      | {name: .metadata.name, subjects: [.subjects[].name]} 
      | select(.subjects[] != "system:masters") 
      | .name'
)

if [ -z "$VIOLATIONS" ]; then
  echo "[PASS] No unauthorized cluster-admin bindings detected."
  exit 0
fi

echo "[FAIL] Unauthorized cluster-admin bindings found:"
echo "$VIOLATIONS"
echo ""


echo "⚠️  This script will SCAN and may DELETE unauthorized cluster-admin bindings."
read -p "Do you want to continue? (yes/no): " CONFIRM

if [[ "$CONFIRM" != "yes" ]]; then
    echo "❌ Action cancelled."
    exit 0
fi

echo "✔️ Confirmation received. Running script..."










echo "=== Step 2: Auto-remediation ==="
for BIND in $VIOLATIONS; do
    echo "Deleting binding: $BIND"
    kubectl delete clusterrolebinding "$BIND"
done

echo ""
echo "=== Step 3: Verifying results ==="
kubectl get clusterrolebindings \
  -o=custom-columns=NAME:.metadata.name,ROLE:.roleRef.name,SUBJECT:.subjects[*].name

echo ""
echo "========== DONE =========="
echo "CIS 4.1.1 compliance restored."
