#!/usr/bin/env bash
# Starting state for the triage lab. It creates a working probe, a client pod and
# five faulty workloads. It does not fix anything and does not create the report.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/starfleet.yaml"
kubectl -n starfleet rollout status deployment/probe --timeout=180s
kubectl -n starfleet rollout status deployment/bridge --timeout=180s
kubectl -n starfleet wait --for=condition=Ready pod/shuttle --timeout=120s
echo "[lab] Ready. Five workloads are faulty on purpose."
