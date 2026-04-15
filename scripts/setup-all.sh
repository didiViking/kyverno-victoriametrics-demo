#!/bin/bash
set -e

echo "🚀 Step 1: Add Helm repo (VictoriaMetrics)"
helm repo add vm https://victoriametrics.github.io/helm-charts/
helm repo update

echo "🚀 Step 2: Install VictoriaMetrics single"
helm upgrade --install vm vm/victoria-metrics-single

echo "🚀 Step 3: Install vmagent with config"
helm upgrade --install vmagent vm/victoria-metrics-agent \
  -f 02-vmagent/vmagent-values.yaml

echo "🚀 Step 4: Install Kyverno"
kubectl apply -f https://raw.githubusercontent.com/kyverno/kyverno/main/config/release/install.yaml

echo "⏳ Waiting for Kyverno to be ready..."
kubectl wait --for=condition=Available deployment -n kyverno --all --timeout=180s

echo "🚀 Step 5: Apply Kyverno policies"
kubectl apply -f 04-policies/

echo "🚀 Step 6: Apply demo namespace"
kubectl create namespace demo-ns --dry-run=client -o yaml | kubectl apply -f -

echo "✅ Setup complete!"
echo "👉 Next: run ./scripts/demo-flow.sh"
