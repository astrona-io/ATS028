#!/usr/bin/env bash
# Starting state: the beacon Deployment has a wrong readiness path and a wrong
# liveness port. The scout Deployment has no probe. Environment only.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/start.yaml"
kubectl -n starfleet wait --for=condition=Ready pod/shuttle --timeout=120s
kubectl -n starfleet rollout status deployment/scout --timeout=180s
echo "[lab] Ready. The beacon pods are expected not to be ready."
