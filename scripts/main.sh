#!/bin/bash

# Load biến môi trường
if [ -f ".env.local" ]; then
    set -o allexport
    source .env.local
    set +o allexport
else
    echo "[ERROR] Missing .env.local"
    exit 1
fi

# Kiểm tra biến bắt buộc
if [ -z "$CLUSTER_NAME" ]; then
    echo "[ERROR] Thiếu CLUSTER_NAME trong .env"
    exit 1
fi

if [ -z "$PROJECT_ID" ]; then
    echo "[ERROR] Thiếu PROJECT_ID trong .env"
    exit 1
fi

# Nếu dùng ZONE thì không dùng REGION
if [ -n "$ZONE" ]; then
    GET_CREDENTIAL_CMD="gcloud container clusters get-credentials $CLUSTER_NAME --zone $ZONE --project $PROJECT_ID"
elif [ -n "$REGION" ]; then
    GET_CREDENTIAL_CMD="gcloud container clusters get-credentials $CLUSTER_NAME --region $REGION --project $PROJECT_ID"
else
    echo "[ERROR] REGION hoặc ZONE phải được khai báo trong .env"
    exit 1
fi

echo "👉 Đang xác minh ...:"
echo ""

$GET_CREDENTIAL_CMD
if [ $? -eq 0 ]; then
    echo "✔️ Lấy credentials thành công!"
else
    echo "❌ Lỗi khi lấy credentials!"
    exit 1
fi

echo ">>> Converting Windows CRLF -> Linux LF for all scripts..."
find ./checks -type f -name "*.sh" -exec sed -i 's/\r$//' {} \;
echo "✔️ Conversion done!"
echo ""

SCRIPTS_DIR="./checks"

if [ ! -d "$SCRIPTS_DIR" ]; then
    echo "[ERROR] Folder scripts không tồn tại: $SCRIPTS_DIR"
    exit 1
fi

# Danh sách scripts với mô tả
declare -A SCRIPT_NAMES=(
    ["cis_4.1.1.sh"]="(RBAC) - Cluster_admin_role_check"
    ["cis_4.1.3.sh"]="(RBAC) - Clusterrole and role wildcard check"
    ["cis_4.1.7.sh"]="(RBAC) - Bind,Impersonate,Escalate role and clusterrole check"
    ["cis_4.2.1.sh"]="(PSS) - Baseline enforcement check"
    ["cis_4.6.1.sh"]="(GeneralPolicy) - Namespace Boundary enforcement check"
    ["cis_5.4.1.sh"]="(Networking) - VPC flowlogs and IntraNodeVisibility check"
)

SCRIPTS=(
    "cis_4.1.1.sh"
    "cis_4.1.3.sh"
    "cis_4.1.7.sh"
    "cis_4.2.1.sh"
    "cis_4.6.1.sh"
    "cis_5.4.1.sh"
)

# Display confirmation menu
echo "=========================================="
echo "        CIS Security Checks Overview"
echo "=========================================="
echo ""
for SCRIPT in "${SCRIPTS[@]}"; do
    echo "✓ $SCRIPT ${SCRIPT_NAMES[$SCRIPT]}"
done
echo ""
echo "=========================================="
echo ""

# Request confirmation
read -p "Do you want to run all checks? (yes/no): " CONFIRM

if [[ "$CONFIRM" != "yes" ]]; then
    echo "❌ Checks cancelled."
    exit 0
fi

echo ""
echo "👉 Chạy tất cả checks..."
echo ""

LOG_FILE="log.txt"
PREVIOUS_LOG="log_previous.txt"

# Initialize temp log array
TEMP_LOG="[]"

for SCRIPT_FILE in "${SCRIPTS[@]}"; do
    echo "Chạy: $SCRIPT_FILE ${SCRIPT_NAMES[$SCRIPT_FILE]}"
    OUTPUT=$(bash "$SCRIPTS_DIR/$SCRIPT_FILE" 2>&1)
    EXIT_CODE=$?

    if [ $EXIT_CODE -eq 0 ]; then
        STATUS="PASS"
    else
        STATUS="FAIL"
    fi

    # Create JSON entry
    DATETIME=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Escape output for JSON
    LOG_MSG=$(echo "$OUTPUT" | tail -1 | sed 's/"/\\"/g' | sed 's/$//' )
    
    # Use descriptive name instead of filename
    CHECK_NAME="${SCRIPT_NAMES[$SCRIPT_FILE]}"
    
    # Append to temp array
    TEMP_LOG=$(echo "$TEMP_LOG" | jq ". += [{\"datetime\": \"$DATETIME\", \"name\": \"$CHECK_NAME\", \"status\": \"$STATUS\", \"log\": \"$LOG_MSG\"}]")
    
    echo "✔️ $SCRIPT_FILE đã chạy xong (Status: $STATUS)"
done

# Keep only last 6 entries
TEMP_LOG=$(echo "$TEMP_LOG" | jq '.[length-6:length]')

# Save current log as previous log before writing new log
if [ -f "$LOG_FILE" ]; then
    cp "$LOG_FILE" "$PREVIOUS_LOG"
fi

# Write to log file
echo "$TEMP_LOG" > "$LOG_FILE"
echo ""
echo "✔️ Log saved to: $LOG_FILE"

echo "" > report.html
python3 generate_report.py log.txt report.html

echo "=== Tất cả checks đã hoàn thành ==="
