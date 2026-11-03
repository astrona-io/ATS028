#!/usr/bin/env bash
# Check: dock has 2 ready replicas and no container restarts.
set -uo pipefail

ready="$(kubectl -n starfleet get deployment dock -o jsonpath='{.status.readyReplicas}' 2>/dev/null || true)"
if [ "$ready" != "2" ]; then
  echo "FAIL: dock must have 2 ready replicas (found: ${ready:-none})"
  exit 1
fi
restarts="$(kubectl -n starfleet get pods -l app=dock -o json | jq '[.items[].status.containerStatuses[0].restartCount] | add')"
if [ "${restarts:-1}" != "0" ]; then
  echo "FAIL: the dock containers restarted $restarts times; wait until only pods from the fixed template remain"
  exit 1
fi
echo "PASS: dock has 2 ready replicas without restarts"
