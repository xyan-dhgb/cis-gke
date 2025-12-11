#!/bin/bash

###############################################################
# CIS 4.1.6 – Limit use of Bind, Escalate, Impersonate permissions
# MODE: AUDIT ONLY – NO AUTO FIX
###############################################################

echo ""
echo "========== CIS 4.1.6: Check Bind, Escalate, Impersonate Permissions =========="

read -p "This script will ONLY scan RBAC for CIS 4.1.6 violations. Continue? (yes/no): " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
    echo "Aborted by user."
    exit 1
fi
echo ""

# Permission list
SENSITIVE_PERMS=("bind" "escalate" "impersonate")

# Ignore system roles
is_system_role() {
    local name="$1"
    local ns="$2"

    [[ "$ns" == "kube-system" ]] && return 0
    [[ "$name" == system:* ]] && return 0
    [[ "$name" == gke:* ]] && return 0
    [[ "$name" == "cluster-admin" ]] && return 0
    [[ "$name" == "kubelet-api-admin" ]] && return 0
    return 1
}

HAS_VIOLATION=false

check_item() {
    local item="$1"
    local type="$2"

    local name
    local ns
    name=$(echo "$item" | jq -r '.metadata.name')
    ns=$(echo "$item" | jq -r '.metadata.namespace // "-"')

    if is_system_role "$name" "$ns"; then
        return
    fi

    for perm in "${SENSITIVE_PERMS[@]}"; do
        echo "$item" | jq -e --arg p "$perm" '.rules[]?.verbs[]? == $p' >/dev/null 2>&1
        if [[ $? -eq 0 ]]; then
            echo "[VIOLATION] $type: $ns/$name → uses '$perm'"
            HAS_VIOLATION=true
        fi
    done
}

###############################################
# Scan Roles
###############################################
echo "=== Checking Roles ==="
while read -r item; do
    check_item "$item" "Role"
done < <(kubectl get roles --all-namespaces -o json | jq -c '.items[]')

###############################################
# Scan ClusterRoles
###############################################
echo ""
echo "=== Checking ClusterRoles ==="
while read -r item; do
    check_item "$item" "ClusterRole"
done < <(kubectl get clusterroles -o json | jq -c '.items[]')

###############################################
# Final Summary
###############################################
echo ""
if [ "$HAS_VIOLATION" = false ]; then
    echo "[PASS] No sensitive permissions found."
    echo "CIS 4.1.6 compliant ✔"
else
    echo "[FAIL] Sensitive permissions detected."
    echo "MANUAL REVIEW REQUIRED (CIS requirement)"
fi

echo ""
exit 0
