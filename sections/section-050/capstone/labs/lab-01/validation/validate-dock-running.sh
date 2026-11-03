#!/usr/bin/env bash
# Check: dock has a ready pod.
set -uo pipefail

ready="$(kubectl -n starfleet get deployment dock -o jsonpath='{.status.readyReplicas}' 2>/dev/null)"
if [ "${ready:-0}" != "1" ]; then
  echo "FAIL: deployment dock has ${ready:-0} ready replicas, expected 1"
  exit 1
fi
echo "PASS: dock is ready"
