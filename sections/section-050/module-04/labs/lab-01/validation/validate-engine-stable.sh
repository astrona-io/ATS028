#!/usr/bin/env bash
# Check: engine runs with no restarts and still has a memory limit of 192Mi or more.
set -uo pipefail

lim="$(kubectl -n starfleet get deployment engine -o jsonpath='{.spec.template.spec.containers[0].resources.limits.memory}' 2>/dev/null)"
case "$lim" in
  *Mi) mib="${lim%Mi}" ;;
  *Gi) mib=$(( ${lim%Gi} * 1024 )) ;;
  "") echo "FAIL: engine must keep a memory limit"; exit 1 ;;
  *) echo "FAIL: use an Mi or Gi value for the memory limit (found: $lim)"; exit 1 ;;
esac
if [ "$mib" -lt 192 ]; then
  echo "FAIL: memory limit $lim is below 192Mi"
  exit 1
fi
restarts="$(kubectl -n starfleet get pods -l app=engine -o jsonpath='{.items[*].status.containerStatuses[0].restartCount}' 2>/dev/null)"
ready="$(kubectl -n starfleet get deployment engine -o jsonpath='{.status.readyReplicas}' 2>/dev/null)"
if [ "${ready:-0}" != "1" ]; then
  echo "FAIL: deployment engine has ${ready:-0} ready replicas, expected 1"
  exit 1
fi
for r in $restarts; do
  if [ "$r" != "0" ]; then
    echo "FAIL: an engine pod has restarted $r times"
    exit 1
  fi
done
echo "PASS: engine is stable with limit $lim"
