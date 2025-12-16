#!/bin/bash

###############################################
# CIS 4.1.1 – Ensure cluster-admin is only used where required
###############################################

# YÊU CẦU:
# - Biến PROJECT_ID, CLUSTER_NAME, ZONE được export từ main.sh
# - main.sh đã chạy get-credentials trước khi chạy file này

# Kiểm tra biến môi trường

echo ""
echo "========== GKE CIS 4.1.1 Automation =========="

echo "=== Detect unauthorized cluster-admin bindings ==="

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
exit 1
