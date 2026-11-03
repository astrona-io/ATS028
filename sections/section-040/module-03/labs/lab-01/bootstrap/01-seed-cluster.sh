#!/usr/bin/env bash
# Starting state: a Deployment whose container writes only to a file. There is
# no volume and no sidecar; the learner adds both.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/starfleet.yaml"
kubectl apply -f "$DIR/manifests/ledger-writer.yaml"
kubectl -n starfleet rollout status deployment/ledger-writer --timeout=180s
echo "[lab] Ready."
