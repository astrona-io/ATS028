#!/usr/bin/env bash
# Starting state for the rollout lab. It creates a working beacon Deployment
# and then updates it to an image tag that does not exist, so the rollout
# is stuck. It does not roll back and it does not record any findings.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/starfleet.yaml"
for d in probe beacon; do
  kubectl -n starfleet rollout status "deployment/$d" --timeout=180s
done
kubectl -n starfleet wait --for=condition=Ready pod/shuttle --timeout=120s

kubectl -n starfleet annotate deployment/beacon kubernetes.io/change-cause="initial release" --overwrite
kubectl -n starfleet set image deployment/beacon web=docker.io/library/python:3.13-alpine-missing
kubectl -n starfleet annotate deployment/beacon kubernetes.io/change-cause="update to a new tag" --overwrite
echo "[lab] Ready. The beacon rollout is stuck on purpose."
