#!/usr/bin/env bash
# Check: 2 ready replicas and no container restarts.
set -uo pipefail

ready="$(kubectl -n starfleet get deployment beacon -o jsonpath='{.status.readyReplicas}' 2>/dev/null || true)"
if [ "$ready" != "2" ]; then
  echo "FAIL: beacon must have 2 ready replicas (found: ${ready:-none})"
  exit 1
fi
restarts="$(kubectl -n starfleet get pods -l app=beacon -o json | jq '[.items[].status.containerStatuses[0].restartCount] | add')"
if [ "${restarts:-1}" != "0" ]; then
  echo "FAIL: the beacon containers restarted $restarts times; wait until only pods from the fixed template remain"
  exit 1
fi
echo "PASS: beacon has 2 ready replicas without restarts"
