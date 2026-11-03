#!/usr/bin/env bash
# Check: beacon has 2 ready replicas.
set -uo pipefail

ready="$(kubectl -n starfleet get deployment beacon -o jsonpath='{.status.readyReplicas}' 2>/dev/null || true)"
if [ "$ready" != "2" ]; then
  echo "FAIL: beacon must have 2 ready replicas (found: ${ready:-none})"
  exit 1
fi
echo "PASS: beacon has 2 ready replicas"
