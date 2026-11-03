#!/usr/bin/env bash
# Check: the beacon pods are all from the fixed template and have no restarts.
set -uo pipefail

total="$(kubectl -n starfleet get pods -l app=beacon --field-selector=status.phase=Running -o json | jq '.items | length')"
if [ "$total" != "2" ]; then
  echo "FAIL: expected 2 running beacon pods (found: $total)"
  exit 1
fi
restarts="$(kubectl -n starfleet get pods -l app=beacon -o json | jq '[.items[].status.containerStatuses[0].restartCount] | add')"
if [ "${restarts:-1}" != "0" ]; then
  echo "FAIL: the beacon containers have restarted $restarts times; wait for the rollout so only fixed pods remain"
  exit 1
fi
echo "PASS: the beacon pods are running without restarts"
