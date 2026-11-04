#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="demo-ns"

echo "======================================"
echo " KYVERNO + VICTORIAMETRICS CLEANUP"
echo "======================================"

echo ""
echo "Step 1: Remove demo Kyverno policies"

kubectl delete validatingpolicy \
  require-observability-labels \
  --ignore-not-found

kubectl delete mutatingpolicy \
  add-safe-observability-labels \
  --ignore-not-found

kubectl delete generatingpolicy \
  generate-configmap \
  --ignore-not-found

kubectl delete imagevalidatingpolicy \
  verify-image-signatures \
  --ignore-not-found

kubectl delete deletingpolicy \
  delete-temporary-configmap \
  --ignore-not-found

echo ""
echo "Step 2: Remove demo namespace"

kubectl delete namespace "$NAMESPACE" \
  --ignore-not-found \
  --wait=true

echo ""
echo "Step 3: Uninstall vmagent"

helm uninstall vmagent --ignore-not-found

echo ""
echo "Step 4: Uninstall VictoriaMetrics Single"

helm uninstall vm --ignore-not-found

echo ""
echo "======================================"
echo " CLEANUP COMPLETE"
echo "======================================"

echo "Kyverno remains installed."
