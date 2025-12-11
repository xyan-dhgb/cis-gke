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

# Danh sách scripts cần chạy
SCRIPTS=(
    "cis_4.1.1.sh"
    "cis_4.1.3.sh"
    "cis_4.1.7.sh"
    "cis_4.2.1.sh"
    "cis_4.6.1.sh"
    "cis_5.4.1.sh"
)

echo "👉 Chạy tất cả checks..."
echo ""

for SCRIPT_FILE in "${SCRIPTS[@]}"; do
    echo "Chạy: $SCRIPT_FILE"
    bash "$SCRIPTS_DIR/$SCRIPT_FILE"
    echo "✔️ $SCRIPT_FILE đã chạy xong"
    echo ""
done

echo "=== Tất cả checks đã hoàn thành ==="
