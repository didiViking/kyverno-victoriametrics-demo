#!/bin/bash
set -e

echo ""
echo "=============================="
echo "🎬 KYVERNO + VM OBSERVABILITY DEMO"
echo "=============================="
echo ""

echo "📌 Step 1: Show policies"
kubectl get clusterpolicy

echo ""
echo "📌 Step 2: Show metrics are flowing"
echo "kyverno_admission_requests_total:"
curl -s "http://localhost:8428/api/v1/query?query=kyverno_admission_requests_total" | jq '.data.result | length'

echo ""
echo "📌 Step 3: Create VALID workload (should pass)"
kubectl apply -f 05-demo-app/good-pod.yaml

echo ""
echo "📌 Step 4: Create INVALID workload (should be blocked)"
kubectl apply -f 05-demo-app/bad-pod.yaml || true

echo ""
echo "📌 Step 5: Create deployment (mutation policy applies)"
kubectl apply -f 05-demo-app/deployment.yaml

echo ""
echo "📌 Step 6: Show updated metrics again"
curl -s "http://localhost:8428/api/v1/query?query=kyverno_admission_requests_total" | jq '.data.result | length'

echo ""
echo "📌 Step 7: Open Grafana (manual step)"
echo "👉 http://localhost:3000"
echo "Dashboard: Kyverno Policy Observability"

echo ""
echo "=============================="
echo "✅ DEMO COMPLETE"
echo "=============================="
