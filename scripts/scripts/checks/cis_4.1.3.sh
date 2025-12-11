#!/bin/bash

###############################################
# CIS 4.1.3 – Minimize wildcard use in Roles and ClusterRoles
# MODE: AUDIT ONLY (NO AUTO-FIX)
###############################################

echo ""
echo "========== GKE CIS 4.1.3: Minimize wildcard use in Roles and ClusterRoles =========="
echo "Project ID      : $PROJECT_ID"
echo "Cluster Name    : $CLUSTER_NAME"
echo "Cluster Location: $ZONE"
echo ""

###############################################
# Confirm before running
###############################################

read -p "This script will SCAN RBAC for CIS violations. Do you want to continue? (yes/no): " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
    echo "Aborted by user."
    exit 1
fi

echo ""

###############################################
# Helper functions
###############################################

# System roles that MUST be ignored
is_system_role() {
    local name="$1"
    local ns="$2"

    [[ "$ns" == "kube-system" ]] && return 0
    [[ "$name" == system:* ]] && return 0
    [[ "$name" == gke:* ]] && return 0
    [[ "$name" == "cluster-admin" ]] && return 0
    [[ "$name" == "kubelet-api-admin" ]] && return 0
    [[ "$name" == "external-metrics-reader" ]] && return 0

    return 1
}

has_wildcard() {
  jq -e '
    .rules[]? |
      (.verbs[]? == "*" or
       .apiGroups[]? == "*" or
       .resources[]? == "*" or
       .resourceNames[]? == "*")
  ' >/dev/null 2>&1
}

###############################################
# 1) SCAN — detect violations
###############################################

echo "=== SCANNING all Roles & ClusterRoles for wildcard violations ==="

HAS_VIOLATION=false

# Scan Roles
while read -r item; do
  name=$(echo "$item" | jq -r '.metadata.name')
  ns=$(echo "$item" | jq -r '.metadata.namespace')

  if is_system_role "$name" "$ns"; then
      continue
  fi

  echo "$item" | has_wildcard
  if [[ $? -eq 0 ]]; then
      echo "[VIOLATION] Role: $ns/$name"
      HAS_VIOLATION=true
  fi
done < <(kubectl get roles --all-namespaces -o json | jq -c '.items[]')

# Scan ClusterRoles
while read -r item; do
  name=$(echo "$item" | jq -r '.metadata.name')

  if is_system_role "$name" "cluster-wide"; then
      continue
  fi

  echo "$item" | has_wildcard
  if [[ $? -eq 0 ]]; then
      echo "[VIOLATION] ClusterRole: $name"
      HAS_VIOLATION=true
  fi
done < <(kubectl get clusterroles -o json | jq -c '.items[]')


###############################################
# 2) FINAL OUTPUT
###############################################

if [ "$HAS_VIOLATION" = false ]; then
    echo ""
    echo "[PASS] No wildcard violations found."
    echo "CIS 4.1.3 compliant ✔"
    exit 0
fi

echo ""
echo "[FAIL] Wildcard violations detected."
echo "Please manually review related YAML files."
echo "CIS 4.1.3 NOT compliant ✖"
echo ""

exit 1
