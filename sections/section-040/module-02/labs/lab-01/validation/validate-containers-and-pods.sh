#!/usr/bin/env bash
# Check: containers lists the container names of the ledger pod template
# (sorted, comma separated) and pods is the number of ledger pods.
set -uo pipefail

names="$(kubectl -n starfleet get deployment ledger -o jsonpath='{.spec.template.spec.containers[*].name}' 2>/dev/null | tr ' ' '\n' | sort | paste -sd, -)"
pods="$(kubectl -n starfleet get pods -l app=ledger --no-headers 2>/dev/null | wc -l | tr -d ' ')"
found_names="$(kubectl -n starfleet get configmap log-findings -o jsonpath='{.data.containers}' 2>/dev/null || true)"
found_pods="$(kubectl -n starfleet get configmap log-findings -o jsonpath='{.data.pods}' 2>/dev/null || true)"
fail=0

if [ "$found_names" != "$names" ]; then
  echo "FAIL: log-findings key containers must be $names (found: ${found_names:-nothing})"
  fail=1
fi
if [ "$found_pods" != "$pods" ]; then
  echo "FAIL: log-findings key pods must be $pods (found: ${found_pods:-nothing})"
  fail=1
fi
[ "$fail" -eq 0 ] && echo "PASS: containers and pods match the ledger Deployment"
exit "$fail"
