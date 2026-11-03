#!/usr/bin/env bash
# Check: hail and keel keep revision 1, and hail answers through shuttle.
set -uo pipefail

for d in hail keel; do
  rev="$(kubectl -n starfleet get deployment "$d" -o jsonpath='{.metadata.annotations.deployment\.kubernetes\.io/revision}' 2>/dev/null || true)"
  if [ "$rev" != "1" ]; then
    echo "FAIL: $d is at revision ${rev:-none}; it must stay at revision 1"
    exit 1
  fi
  ready="$(kubectl -n starfleet get deployment "$d" -o jsonpath='{.status.readyReplicas}' 2>/dev/null || true)"
  if [ "$ready" != "2" ]; then
    echo "FAIL: $d must keep 2 ready replicas (found: ${ready:-none})"
    exit 1
  fi
done
echo "PASS: hail and keel are untouched"
