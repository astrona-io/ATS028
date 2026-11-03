#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

CODE="$(kubectl -n starfleet logs deploy/ledger -c audit --tail=50 | grep -o 'code=E[0-9]*' | head -1 | cut -d= -f2)"
KEY="$(kubectl -n starfleet logs -l app=fuse -c app --previous 2>/dev/null | grep -o 'FUSE_KEY_[0-9]*' | head -1)"
if [ -z "$KEY" ]; then
  KEY="$(kubectl -n starfleet logs -l app=fuse -c app 2>/dev/null | grep -o 'FUSE_KEY_[0-9]*' | head -1)"
fi
PODS="$(kubectl -n starfleet get pods -l app=ledger --no-headers | wc -l | tr -d ' ')"
NAMES="$(kubectl -n starfleet get deployment ledger -o jsonpath='{.spec.template.spec.containers[*].name}' | tr ' ' '\n' | sort | paste -sd, -)"

kubectl -n starfleet create configmap log-findings \
  --from-literal=audit-code="$CODE" \
  --from-literal=fuse-key="$KEY" \
  --from-literal=containers="$NAMES" \
  --from-literal=pods="$PODS"
echo "[solution] Applied."
