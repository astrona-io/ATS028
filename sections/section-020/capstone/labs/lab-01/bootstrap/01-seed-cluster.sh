#!/usr/bin/env bash
# Starting state: hail has a readiness probe on the wrong port, dock needs 30
# seconds to listen and its liveness probe kills it, keel has no probes.
# Environment only: the findings ConfigMap is not created.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/start.yaml"
kubectl -n starfleet wait --for=condition=Ready pod/shuttle --timeout=120s
kubectl -n starfleet rollout status deployment/keel --timeout=180s
echo "[lab] Ready. The hail pods are expected to stay not ready and the dock pods to restart."
