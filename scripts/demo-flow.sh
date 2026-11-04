#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="demo-ns"
VM_URL="${VM_URL:-http://localhost:8428}"
POLICY_DIR="04-policies"
APP_DIR="05-demo-app"

echo "======================================"
echo " KYVERNO + VICTORIAMETRICS DEMO"
echo "======================================"

# Check prerequisites
for cmd in kubectl curl jq; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "ERROR: Missing dependency: $cmd"
    exit 1
  fi
done

kubectl get namespace "$NAMESPACE" >/dev/null

echo ""
echo "Step 1: Show available Kyverno policy types"

kubectl get validatingpolicies.policies.kyverno.io
kubectl get mutatingpolicies.policies.kyverno.io
kubectl get generatingpolicies.policies.kyverno.io
kubectl get imagevalidatingpolicies.policies.kyverno.io
kubectl get deletingpolicies.policies.kyverno.io

echo ""
echo "Step 2: Apply demo policies"

kubectl apply -f "$POLICY_DIR/"

echo ""
echo "Step 3: Check VictoriaMetrics connectivity"

curl --fail --silent --show-error \
  "$VM_URL/health" >/dev/null

echo "VictoriaMetrics is reachable."

echo ""
echo "Step 4: Show admission metrics before tests"

curl --fail --silent --show-error --get \
  "$VM_URL/api/v1/query" \
  --data-urlencode \
  'query=sum by (request_allowed) (increase(kyverno_admission_requests_total[5m]))' \
  | jq '.data.result'

echo ""
echo "Step 5: Test signed image (expected: admitted)"

kubectl apply -f "$APP_DIR/good-pod.yaml"

echo ""
echo "Step 6: Test unsigned image (expected: denied)"

if output=$(kubectl apply -f "$APP_DIR/bad-pod.yaml" 2>&1); then
  echo "$output"
  echo "ERROR: Unsigned-image Pod was admitted unexpectedly."
  exit 1
else
  echo "$output"

  if ! echo "$output" | grep -Eqi \
    'signature|verifyImageSignatures|verify-image-signatures'; then
    echo "ERROR: Pod was rejected for an unexpected reason."
    exit 1
  fi

  echo "Unsigned-image Pod rejected as expected."
fi

echo ""
echo "Step 7: Wait for the next metrics scrape"

sleep 20

echo ""
echo "Step 8: Show admission metrics after tests"

curl --fail --silent --show-error --get \
  "$VM_URL/api/v1/query" \
  --data-urlencode \
  'query=sum by (request_allowed) (increase(kyverno_admission_requests_total[5m]))' \
  | jq '.data.result'

echo ""
echo "Step 9: Show demo Pods"

kubectl get pods -n "$NAMESPACE"

echo ""
echo "Step 10: Open dashboards"

echo "VictoriaMetrics VMUI: $VM_URL/vmui/"
echo "Grafana: http://localhost:3000"

echo ""
echo "======================================"
echo " DEMO COMPLETE"
echo "======================================"
