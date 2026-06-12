#!/usr/bin/env bash
set -euo pipefail
echo "Running kustomize build validation"
if command -v kubectl >/dev/null 2>&1; then
  kubectl kustomize . > /tmp/kustomize_out.yaml
  echo "Performing kubectl dry-run apply"
  kubectl apply --dry-run=client -f /tmp/kustomize_out.yaml
  echo "kubectl dry-run completed"
else
  echo "kubectl not found. Please install kubectl to run full validation."
  exit 0
fi
