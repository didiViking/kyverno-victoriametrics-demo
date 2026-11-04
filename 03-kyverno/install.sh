#!/usr/bin/env bash
set -euo pipefail

KYVERNO_VERSION="v1.19.2"

kubectl apply -f \
  "https://github.com/kyverno/kyverno/releases/download/${KYVERNO_VERSION}/install.yaml"
