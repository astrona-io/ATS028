#!/usr/bin/env bash
# Check: captain is ready and requests at most 1 CPU core.
set -uo pipefail

cpu="$(kubectl -n starfleet get deployment captain -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}' 2>/dev/null)"
case "$cpu" in
  "") ;;
  *m) if [ "${cpu%m}" -gt 1000 ]; then echo "FAIL: cpu request $cpu is above 1 core"; exit 1; fi ;;
  *) if [ "$cpu" != "1" ] && [ "$cpu" != "0" ]; then echo "FAIL: cpu request $cpu is above 1 core"; exit 1; fi ;;
esac
ready="$(kubectl -n starfleet get deployment captain -o jsonpath='{.status.readyReplicas}' 2>/dev/null)"
if [ "${ready:-0}" != "1" ]; then
  echo "FAIL: deployment captain has ${ready:-0} ready replicas, expected 1"
  exit 1
fi
echo "PASS: captain is scheduled and ready"
