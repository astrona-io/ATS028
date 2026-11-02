#!/usr/bin/env bash
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-028-lab-050-02-01" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
bootstrap_directory="$(cd "$(dirname "$0")" && pwd)"
kubectl apply -f "$bootstrap_directory/manifests/start.yaml"
kubectl -n starfleet wait --for=condition=Ready pod/shuttle --timeout=120s
if kubectl -n starfleet get configmap probe-settings >/dev/null 2>&1; then
  printf 'Missing dependency was unexpectedly present\n' >&2
  exit 1
fi
