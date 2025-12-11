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

echo "👉 Đangxác minh ...:"
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

# ====== Menu có thứ tự ======

SCRIPTS_DIR="./checks"

if [ ! -d "$SCRIPTS_DIR" ]; then
    echo "[ERROR] Folder scripts không tồn tại: $SCRIPTS_DIR"
    exit 1
fi

# Danh sách option theo thứ tự
ORDERED_OPTIONS=(
    "4.1.1 Checks"
    "4.1.3 Checks"
    "4.1.7 Checks"
    "4.2.1 Checks"
    "4.6.1 Checks"
    "5.4.1 Checks"
    "Exit"
)

# Mapping option -> script
declare -A MENU
MENU["4.1.1 Checks"]="cis_4.1.1.sh"
MENU["4.1.3 Checks"]="cis_4.1.3.sh"
MENU["4.1.7 Checks"]="cis_4.1.7.sh"
MENU["4.2.1 Checks"]="cis_4.2.1.sh"
MENU["4.6.1 Checks"]="cis_4.6.1.sh"
MENU["5.4.1 Checks"]="cis_5.4.1.sh"
MENU["Exit"]="exit"

while true; do
    echo "=== Chọn script cần chạy ==="

    for i in "${!ORDERED_OPTIONS[@]}"; do
        index=$((i+1))
        echo "$index) ${ORDERED_OPTIONS[$i]}"
    done

    read -p "Nhập số lựa chọn: " CHOICE

    # Convert choice to index
    OPT_INDEX=$((CHOICE-1))
    SELECTED="${ORDERED_OPTIONS[$OPT_INDEX]}"

    if [ -z "$SELECTED" ]; then
        echo "[ERROR] Lựa chọn không hợp lệ, thử lại."
        continue
    fi

    if [ "$SELECTED" == "Exit" ]; then
        echo "Thoát chương trình."
        break
    fi

    SCRIPT_FILE="${MENU[$SELECTED]}"
    echo "👉 Chạy script: $SELECTED – $SCRIPT_FILE"
    bash "$SCRIPTS_DIR/$SCRIPT_FILE"
    echo "=== Script đã chạy xong ==="
    echo ""
done
