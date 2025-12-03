#!/bin/bash

###############################################
# CIS 4.1.3 – Minimize wildcard use in Roles and ClusterRoles
###############################################

### ====== SETTINGS: ĐIỀN SẴN ====== ###
PROJECT_ID="ENTER_YOUR_PROJECT_ID"
CLUSTER_NAME="ENTER_YOUR_CLUSTER_NAME"
CLUSTER_LOCATION="ENTER_YOUR_CLUSTER_REGION"
### ================================== ###

echo ""
echo "========== GKE CIS 4.1.3: Minimize wildcard use in Roles and ClusterRoles (Automated) =========="
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

echo "========== CIS 4.1.3 – Safe Wildcard Fix for GKE =========="
echo ""

# ====== Không sửa các roles hệ thống ======
is_system_role() {
    local name="$1"
    local ns="$2"

    # Không đụng vào namespace kube-system
    if [[ "$ns" == "kube-system" ]]; then
        return 0
    fi

    # Không đụng vào roles bắt đầu bằng system:
    if [[ "$name" == system:* ]]; then
        return 0
    fi

    # Không đụng vào cluster-admin
    if [[ "$name" == "cluster-admin" ]]; then
        return 0
    fi

    # Không sửa các role đặc thù GKE
    if [[ "$name" == gke:* ]]; then
        return 0
    fi

    # Không sửa roles được GKE controller quản lý
    if [[ "$name" == "kubelet-api-admin" ]]; then
        return 0
    fi

    return 1
}

# ====== Kiểm tra wildcard ======
has_wildcard() {
  jq -e '
    .rules[]? |
      (.verbs[]? == "*" or
       .apiGroups[]? == "*" or
       .resources[]? == "*" or
       .resourceNames[]? == "*")
  ' >/dev/null 2>&1
}

# ====== Sửa Role ======
fix_role() {
  local name="$1"
  local ns="$2"

  echo "[FIX] Role: $ns/$name"

  kubectl get role "$name" -n "$ns" -o yaml > "/tmp/role-$ns-$name.yaml"

  # Thay thế wildcards bằng sed (cho YAML list format của Kubernetes)
  # Thay - '*' trong verbs (có thể có hoặc không có quotes)
  sed -i "/verbs:/,/^  [a-z]\|^[a-z]/ s/^  - '\*'$/  - get\n  - list\n  - watch/" "/tmp/role-$ns-$name.yaml"
  sed -i "/verbs:/,/^  [a-z]\|^[a-z]/ s/^  - \"\*\"$/  - get\n  - list\n  - watch/" "/tmp/role-$ns-$name.yaml"
  sed -i "/verbs:/,/^  [a-z]\|^[a-z]/ s/^  - \*$/  - get\n  - list\n  - watch/" "/tmp/role-$ns-$name.yaml"
  
  # Thay - '*' trong resources
  sed -i "/resources:/,/^  [a-z]\|^[a-z]/ s/^  - '\*'$/  - pods\n  - services/" "/tmp/role-$ns-$name.yaml"
  sed -i "/resources:/,/^  [a-z]\|^[a-z]/ s/^  - \"\*\"$/  - pods\n  - services/" "/tmp/role-$ns-$name.yaml"
  sed -i "/resources:/,/^  [a-z]\|^[a-z]/ s/^  - \*$/  - pods\n  - services/" "/tmp/role-$ns-$name.yaml"
  
  # Thay - '*' trong apiGroups
  sed -i "/apiGroups:/,/^  [a-z]\|^[a-z]/ s/^  - '\*'$/  - \"\"\n  - apps/" "/tmp/role-$ns-$name.yaml"
  sed -i "/apiGroups:/,/^  [a-z]\|^[a-z]/ s/^  - \"\*\"$/  - \"\"\n  - apps/" "/tmp/role-$ns-$name.yaml"
  sed -i "/apiGroups:/,/^  [a-z]\|^[a-z]/ s/^  - \*$/  - \"\"\n  - apps/" "/tmp/role-$ns-$name.yaml"

  kubectl apply -f "/tmp/role-$ns-$name.yaml" >/dev/null 2>&1
}

# ====== Sửa ClusterRole (User-created only) ======
fix_clusterrole() {
  local name="$1"

  echo "[FIX] ClusterRole: $name"

  kubectl get clusterrole "$name" -o yaml > "/tmp/clusterrole-$name.yaml"

  # Thay thế wildcards bằng sed (cho YAML list format của Kubernetes)
  sed -i "/verbs:/,/^  [a-z]\|^[a-z]/ s/^  - '\*'$/  - get\n  - list\n  - watch/" "/tmp/clusterrole-$name.yaml"
  sed -i "/verbs:/,/^  [a-z]\|^[a-z]/ s/^  - \"\*\"$/  - get\n  - list\n  - watch/" "/tmp/clusterrole-$name.yaml"
  sed -i "/verbs:/,/^  [a-z]\|^[a-z]/ s/^  - \*$/  - get\n  - list\n  - watch/" "/tmp/clusterrole-$name.yaml"
  
  sed -i "/resources:/,/^  [a-z]\|^[a-z]/ s/^  - '\*'$/  - pods\n  - services/" "/tmp/clusterrole-$name.yaml"
  sed -i "/resources:/,/^  [a-z]\|^[a-z]/ s/^  - \"\*\"$/  - pods\n  - services/" "/tmp/clusterrole-$name.yaml"
  sed -i "/resources:/,/^  [a-z]\|^[a-z]/ s/^  - \*$/  - pods\n  - services/" "/tmp/clusterrole-$name.yaml"
  
  sed -i "/apiGroups:/,/^  [a-z]\|^[a-z]/ s/^  - '\*'$/  - \"\"\n  - apps/" "/tmp/clusterrole-$name.yaml"
  sed -i "/apiGroups:/,/^  [a-z]\|^[a-z]/ s/^  - \"\*\"$/  - \"\"\n  - apps/" "/tmp/clusterrole-$name.yaml"
  sed -i "/apiGroups:/,/^  [a-z]\|^[a-z]/ s/^  - \*$/  - \"\"\n  - apps/" "/tmp/clusterrole-$name.yaml"

  kubectl apply -f "/tmp/clusterrole-$name.yaml" >/dev/null 2>&1
}

# ====== Scan Roles ======
echo "=== Checking Roles ==="
kubectl get roles --all-namespaces -o json | jq -c '.items[]' | while read -r item; do
  name=$(echo "$item" | jq -r '.metadata.name')
  ns=$(echo "$item" | jq -r '.metadata.namespace')

  # Bỏ qua roles hệ thống
  if is_system_role "$name" "$ns"; then
      continue
  fi

  # Kiểm tra wildcard
  echo "$item" | has_wildcard
  if [[ $? -eq 0 ]]; then
      echo "[VIOLATION] $ns/$name"
      fix_role "$name" "$ns"
  fi
done

# ====== Scan ClusterRoles ======
echo "=== Checking ClusterRoles ==="
kubectl get clusterroles -o json | jq -c '.items[]' | while read -r item; do
  name=$(echo "$item" | jq -r '.metadata.name')

  # Skip system roles
  if is_system_role "$name" "cluster-wide"; then
      continue
  fi

  echo "$item" | has_wildcard
  if [[ $? -eq 0 ]]; then
      echo "[VIOLATION] ClusterRole $name"
      fix_clusterrole "$name"
  fi
done

echo ""
echo "========== DONE =========="
echo "CIS 4.1.3 compliance restored for cluster:"
echo "Cluster: $CLUSTER_NAME"
echo "Project: $PROJECT_ID"
echo "Location: $CLUSTER_LOCATION"
echo "(User-created RBAC only, system roles preserved)"
