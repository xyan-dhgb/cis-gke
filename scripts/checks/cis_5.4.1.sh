#!/bin/bash

###############################################################
# CIS 5.4.1 – Check VPC Flow Logs + Intra-node Visibility
# REQUIRE: user manually sets CLUSTER + NETWORK INFO
###############################################################


echo ""
echo "========== CIS 5.4.1: SCAN FlowLogs and IntraNode Visibility =========="
read -p "Do you want to run this scan? (yes/no): " CONFIRM

if [[ "$CONFIRM" != "yes" ]]; then
    echo "Aborted by user."
    exit 1
fi


############################
# CHECK VPC FLOW LOGS
############################
echo "→ Checking VPC Flow Logs for subnet '$SUBNET'..."

FLOW_LOGS=$(gcloud compute networks subnets describe "$SUBNET" \
    --region "$REGION" \
    --format="value(enableFlowLogs)" 2>/dev/null)

if [[ "$FLOW_LOGS" == "True" ]]; then
    echo "[PASS] VPC Flow Logs are ENABLED ✓"
else
    echo "[FAIL] VPC Flow Logs are DISABLED ✗"

    read -p "Do you want to ENABLE Flow Logs for '$SUBNET'? (yes/no): " FIX_FLOW
    if [[ "$FIX_FLOW" == "yes" ]]; then
        echo "→ Enabling Flow Logs..."
        gcloud compute networks subnets update "$SUBNET" \
            --region "$REGION" \
            --enable-flow-logs
        echo "[DONE] Flow Logs enabled."
    else
        echo "[SKIP] Not enabling flow logs."
    fi
fi

echo ""


############################
# CHECK INTRA-NODE VISIBILITY
############################
echo "→ Checking Intra-node Visibility for cluster '$CLUSTER_NAME'..."

INTRA=$(gcloud container clusters describe "$CLUSTER_NAME" \
    --region "$ZONE" \
    --format="value(networkConfig.enableIntraNodeVisibility)" 2>/dev/null)

if [[ "$INTRA" == "True" ]]; then
    echo "[PASS] Intra-node Visibility is ENABLED ✓"
else
    echo "[FAIL] Intra-node Visibility is DISABLED ✗"

    read -p "Do you want to ENABLE Intra-node Visibility? (yes/no): " FIX_INTRA
    if [[ "$FIX_INTRA" == "yes" ]]; then
        echo "→ Enabling intra-node visibility..."
        gcloud container clusters update "$CLUSTER_NAME" \
            --zone "$ZONE" \
            --enable-intra-node-visibility
        echo "[DONE] Intra-node Visibility enabled."
    else
        echo "[SKIP] Not enabling intra-node visibility."
    fi
fi

echo ""
echo "========== DONE =========="
echo ""
exit 0
