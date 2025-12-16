#!/bin/bash

###############################################################
# CIS 5.4.1 – Check VPC Flow Logs + Intra-node Visibility
# REQUIRE: user manually sets CLUSTER + NETWORK INFO
###############################################################


echo ""
echo "========== CIS 5.4.1: SCAN FlowLogs and IntraNode Visibility =========="


############################
# CHECK VPC FLOW LOGS
############################
echo "→ Checking VPC Flow Logs for subnet '$SUBNET'..."

FLOW_LOGS=$(gcloud compute networks subnets describe "$SUBNET" \
    --region "$REGION" \
    --format="value(enableFlowLogs)" 2>/dev/null)

FLOW_STATUS="FAIL"
if [[ "$FLOW_LOGS" == "True" ]]; then
    echo "[PASS] VPC Flow Logs are ENABLED ✓"
    FLOW_STATUS="PASS"
else
    echo "[FAIL] VPC Flow Logs are DISABLED ✗"
fi

echo ""


############################
# CHECK INTRA-NODE VISIBILITY
############################
echo "→ Checking Intra-node Visibility for cluster '$CLUSTER_NAME'..."

INTRA=$(gcloud container clusters describe "$CLUSTER_NAME" \
    --region "$ZONE" \
    --format="value(networkConfig.enableIntraNodeVisibility)" 2>/dev/null)

INTRA_STATUS="FAIL"
if [[ "$INTRA" == "True" ]]; then
    echo "[PASS] Intra-node Visibility is ENABLED ✓"
    INTRA_STATUS="PASS"
else
    echo "[FAIL] Intra-node Visibility is DISABLED ✗"
fi

echo ""
echo "========== DONE =========="

if [[ "$FLOW_STATUS" == "PASS" && "$INTRA_STATUS" == "PASS" ]]; then
    echo "[PASS] All checks passed - VPC Flow Logs: $FLOW_STATUS, Intra-node Visibility: $INTRA_STATUS"
    exit 0
else
    echo "[FAIL] Some checks failed - VPC Flow Logs: $FLOW_STATUS, Intra-node Visibility: $INTRA_STATUS"
    exit 1
fi
