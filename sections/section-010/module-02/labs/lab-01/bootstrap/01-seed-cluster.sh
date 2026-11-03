#!/usr/bin/env bash
# Starting state for the migration lab. Environment only: it creates the probe
# application, the scout-reader service account and the ConfigMap that holds
# the legacy manifests. It does not create the Role, RoleBinding,
# PriorityClass or findings the learner must write.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/starfleet.yaml"
kubectl apply -f "$DIR/manifests/legacy.yaml"
kubectl -n starfleet rollout status deployment/probe --timeout=180s
kubectl -n starfleet wait --for=condition=Ready pod/shuttle --timeout=120s
echo "[lab] Ready."
