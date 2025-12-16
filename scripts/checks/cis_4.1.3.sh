#!/bin/bash

###############################################
# CIS 4.1.3 – Minimize wildcard use in Roles and ClusterRoles
# MODE: AUDIT ONLY (NO AUTO-FIX)
###############################################

echo ""
echo "========== GKE CIS 4.1.3: Minimize wildcard use in Roles and ClusterRoles =========="
###############################################
# Confirm before running
###############################################

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
VIOLATION_LIST=()

# Scan Roles
while read -r item; do
  name=$(echo "$item" | jq -r '.metadata.name')
  ns=$(echo "$item" | jq -r '.metadata.namespace')

  if is_system_role "$name" "$ns"; then
      continue
  fi

  echo "$item" | has_wildcard
  if [[ $? -eq 0 ]]; then
      HAS_VIOLATION=true
      VIOLATION_LIST+=("Role: $ns/$name")
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
      HAS_VIOLATION=true
      VIOLATION_LIST+=("ClusterRole: $name")
  fi
done < <(kubectl get clusterroles -o json | jq -c '.items[]')

###############################################
# 2) FINAL OUTPUT
###############################################

echo ""

if [ "$HAS_VIOLATION" = false ]; then
    echo "[PASS] No wildcard violations found. "
    exit 0
fi

echo "[FAIL] Wildcard violations detected: ${#VIOLATION_LIST[@]} items - ${VIOLATION_LIST[*]}"
exit 1
