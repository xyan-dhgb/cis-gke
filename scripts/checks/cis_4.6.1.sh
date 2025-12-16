#!/bin/bash

###############################################################
# CIS 4.6.1 – Namespace Boundaries Audit (NetworkPolicy / ResourceQuota / RBAC)
# MODE: AUDIT ONLY – LOG PASS/WARN
###############################################################

echo ""
echo "========== Namespace Boundaries Audit (PASS/WARN) =========="

# Function: check if namespace is system/managed
is_system_ns() {
    local ns="$1"
    [[ "$ns" == "kube-system" ]] && return 0
    [[ "$ns" == "kube-public" ]] && return 0
    [[ "$ns" == "kube-node-lease" ]] && return 0
    [[ "$ns" == gke-* ]] && return 0
    [[ "$ns" == gmp-* ]] && return 0
    return 1
}

# Collect user namespaces
NS_LIST=()
for ns_item in $(kubectl get ns -o json | jq -c '.items[]'); do
    ns_name=$(echo "$ns_item" | jq -r '.metadata.name')
    if is_system_ns "$ns_name"; then
        continue
    fi
    NS_LIST+=("$ns_name")
done

# Report header
echo ""
echo "Namespace Boundaries Report"
echo "---------------------------"

WARN_COUNT=0
PASS_COUNT=0

# Loop over namespaces
for ns in "${NS_LIST[@]}"; do
    echo ""
    echo "Namespace: $ns"

    # Check NetworkPolicy
    NP_COUNT=$(kubectl get networkpolicy -n "$ns" --no-headers 2>/dev/null | wc -l)
    if [[ "$NP_COUNT" -gt 0 ]]; then
        echo "  NetworkPolicy: PASS ($NP_COUNT policies found)"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo "  NetworkPolicy: WARN (no policies found)"
        WARN_COUNT=$((WARN_COUNT + 1))
    fi

    # Check ResourceQuota
    RQ_COUNT=$(kubectl get resourcequota -n "$ns" --no-headers 2>/dev/null | wc -l)
    if [[ "$RQ_COUNT" -gt 0 ]]; then
        echo "  ResourceQuota: PASS ($RQ_COUNT quotas found)"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo "  ResourceQuota: WARN (no quotas found)"
        WARN_COUNT=$((WARN_COUNT + 1))
    fi

    # Check RBAC cross-namespace: roles granting access to other namespaces
    CROSS_ROLE_COUNT=$(kubectl get roles,clusterroles -n "$ns" -o json 2>/dev/null | jq '[.items[] | .rules[]? | select(.resources? != null) | select(.resources[] | test(".*"))] | length')
    if [[ "$CROSS_ROLE_COUNT" -gt 0 ]]; then
        echo "  RBAC cross-namespace: WARN ($CROSS_ROLE_COUNT potentially over-permissive rules)"
        WARN_COUNT=$((WARN_COUNT + 1))
    else
        echo "  RBAC cross-namespace: PASS"
        PASS_COUNT=$((PASS_COUNT + 1))
    fi
done

echo ""
echo "[PASS] Namespace Boundaries audit complete - $WARN_COUNT warnings, $PASS_COUNT passed for ${#NS_LIST[@]} namespaces"
exit 0

