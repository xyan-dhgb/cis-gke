#!/bin/bash

###############################################################
# CIS 4.2.1 – Ensure Pod Security Standard Baseline or stricter
# MODE: AUDIT + MANUAL PROMPT TO ENABLE
###############################################################

echo ""
echo "========== CIS 4.2.1: Pod Security Standard Baseline Enforcement =========="
read -p "This script will scan namespaces for Pod Security enforcement. Continue? (yes/no): " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
    echo "Aborted by user."
    exit 1
fi
echo ""

HAS_VIOLATION=false
VIOLATIONS=()

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

# Scan all user namespaces safely (process substitution avoids subshell issue)
while read -r ns_name; do
    if is_system_ns "$ns_name"; then
        continue
    fi

    enforce_level=$(kubectl get ns "$ns_name" -o json | jq -r '.metadata.labels["pod-security.kubernetes.io/enforce"] // "none"')

    if [[ "$enforce_level" != "baseline" && "$enforce_level" != "restricted" ]]; then
        HAS_VIOLATION=true
        VIOLATIONS+=("$ns_name")
    fi
done < <(kubectl get ns -o json | jq -r '.items[].metadata.name')

# Log violations first
if [[ "$HAS_VIOLATION" = true ]]; then
    echo "[FAIL]"
    echo "=== VIOLATIONS FOUND ==="
    for ns_name in "${VIOLATIONS[@]}"; do
        enforce_level=$(kubectl get ns "$ns_name" -o json | jq -r '.metadata.annotations["pod-security.kubernetes.io/enforce"] // "none"')
        echo "[VIOLATION] Namespace '$ns_name' is NOT enforcing Pod Security Baseline or higher. Current enforce level: $enforce_level"
    done
    echo ""
else
    echo "[PASS] All user namespaces enforce Pod Security Baseline or higher."
    echo "CIS 4.2.1 compliant ✔"
    exit 0
fi

# Prompt for manual fix for each violating namespace
for ns_name in "${VIOLATIONS[@]}"; do
    read -p "Do you want to enable PSS Baseline for namespace '$ns_name'? (yes/no): " ENABLE
    if [[ "$ENABLE" == "yes" ]]; then
        echo "Applying Pod Security Baseline to namespace '$ns_name'..."
        kubectl label ns "$ns_name" \
            pod-security.kubernetes.io/enforce=baseline \
            pod-security.kubernetes.io/audit=baseline \
            pod-security.kubernetes.io/warn=baseline \
            --overwrite
        echo "Done."
    else
        echo "Skipping namespace '$ns_name'."
    fi
done

echo ""
echo "=== DONE ==="
echo ""
exit 0
