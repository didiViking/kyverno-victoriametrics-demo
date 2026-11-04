#!/usr/bin/env bash
set -euo pipefail

KYVERNO_VERSION="v1.19.2"
NAMESPACE="demo-ns"

echo "======================================"
echo " KYVERNO + VICTORIAMETRICS SETUP"
echo "======================================"

# Check prerequisites
for cmd in kubectl helm; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "ERROR: $cmd is not installed."
    exit 1
  fi
done

echo ""
echo "Step 1: Add VictoriaMetrics Helm repository"

helm repo add vm \
  https://victoriametrics.github.io/helm-charts/ \
  --force-update

helm repo update

echo ""
echo "Step 2: Install VictoriaMetrics Single"

helm upgrade --install vm vm/victoria-metrics-single \
  --wait \
  --timeout 5m

echo ""
echo "Step 3: Install vmagent"

helm upgrade --install vmagent vm/victoria-metrics-agent \
  -f 02-vmagent/vmagent-values.yaml \
  --wait \
  --timeout 5m

echo ""
echo "Step 4: Install Kyverno ${KYVERNO_VERSION}"

kubectl apply -f \
  "https://github.com/kyverno/kyverno/releases/download/${KYVERNO_VERSION}/install.yaml"

echo ""
echo "Waiting for Kyverno controllers..."

kubectl rollout status deployment/kyverno-admission-controller \
  -n kyverno --timeout=300s

kubectl rollout status deployment/kyverno-background-controller \
  -n kyverno --timeout=300s

kubectl rollout status deployment/kyverno-reports-controller \
  -n kyverno --timeout=300s

kubectl rollout status deployment/kyverno-cleanup-controller \
  -n kyverno --timeout=300s

echo ""
echo "Step 5: Verify CEL policy APIs"

for crd in \
  validatingpolicies.policies.kyverno.io \
  mutatingpolicies.policies.kyverno.io \
  generatingpolicies.policies.kyverno.io \
  imagevalidatingpolicies.policies.kyverno.io \
  deletingpolicies.policies.kyverno.io
do
  kubectl wait \
    --for=condition=Established \
    "crd/$crd" \
    --timeout=180s
done

echo ""
echo "Step 6: Create demo namespace"

kubectl create namespace "$NAMESPACE" \
  --dry-run=client -o yaml | kubectl apply -f -

echo ""
echo "Step 7: Verify services"

kubectl get pods -n kyverno
kubectl get svc -n kyverno

echo ""
echo "VictoriaMetrics:"
helm status vm

echo ""
echo "vmagent:"
helm status vmagent

echo ""
echo "======================================"
echo " SETUP COMPLETE"
echo "======================================"

echo "Next: run ./scripts/demo-flow.sh"
