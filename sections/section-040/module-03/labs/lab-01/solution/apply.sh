#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl apply -f "$DIR/ledger-writer.yaml"
kubectl -n starfleet rollout status deployment/ledger-writer --timeout=180s
echo "[solution] Applied."
