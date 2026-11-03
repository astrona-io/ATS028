#!/usr/bin/env bash
# Starting state: beacon needs 45 seconds to listen and has a liveness probe
# that kills it after about 15 seconds. Environment only.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/start.yaml"
kubectl -n starfleet wait --for=condition=Ready pod/shuttle --timeout=120s
echo "[lab] Ready. The beacon pods are expected to restart in a loop."
