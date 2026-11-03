#!/usr/bin/env bash
# Starting state for the debugging lab. It creates the workloads, including the
# pod scout (listens on 9090) and the Service scout (targetPort 8080, wrong).
# It records the UID of scout so that the validation can tell whether the pod was
# replaced. It does not create the findings ConfigMap or the ephemeral container.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/starfleet.yaml"
kubectl -n starfleet rollout status deployment/probe --timeout=180s
kubectl -n starfleet wait --for=condition=Ready pod/shuttle pod/scout --timeout=180s
uid="$(kubectl -n starfleet get pod scout -o jsonpath='{.metadata.uid}')"
kubectl -n default create configmap lab-baseline --from-literal=scout-uid="$uid" \
  --dry-run=client -o yaml | kubectl apply -f -
echo "[lab] Ready."
