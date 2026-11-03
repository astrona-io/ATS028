#!/usr/bin/env bash
# Starting state for the capstone. It creates the workloads, including two
# faults (hail readiness port, dock image) and the pod beacon to inspect. It records
# the UID of beacon so that the validation can tell whether the pod was replaced.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/starfleet.yaml"
kubectl -n starfleet rollout status deployment/probe --timeout=180s
kubectl -n starfleet wait --for=condition=Ready pod/shuttle pod/beacon --timeout=180s
uid="$(kubectl -n starfleet get pod beacon -o jsonpath='{.metadata.uid}')"
kubectl -n default create configmap lab-baseline --from-literal=beacon-uid="$uid" \
  --dry-run=client -o yaml | kubectl apply -f -
echo "[lab] Ready. hail and dock are faulty on purpose."
