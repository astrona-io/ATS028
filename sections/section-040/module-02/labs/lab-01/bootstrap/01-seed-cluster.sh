#!/usr/bin/env bash
# Starting state: the ledger Deployment (two containers, three pods) and the
# fuse Deployment (crash loop). The error code and the variable name are random
# so that the answers cannot be guessed. The findings ConfigMap is not created.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

CODE="E$(( (RANDOM % 900) + 100 ))"
KEY="FUSE_KEY_$(( (RANDOM % 900) + 100 ))"

kubectl apply -f "$DIR/manifests/starfleet.yaml"
sed -e "s/__CODE__/$CODE/" -e "s/__KEY__/$KEY/" "$DIR/manifests/workloads.yaml" | kubectl apply -f -
kubectl -n starfleet rollout status deployment/ledger --timeout=180s
kubectl -n starfleet wait --for=jsonpath='{.status.containerStatuses[0].restartCount}'=1 pod -l app=fuse --timeout=120s || true
echo "[lab] Ready."
