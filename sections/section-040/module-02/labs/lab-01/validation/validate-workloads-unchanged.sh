#!/usr/bin/env bash
# Check: the Deployments still exist with their original shape.
set -uo pipefail

fail=0
replicas="$(kubectl -n starfleet get deployment ledger -o jsonpath='{.spec.replicas}' 2>/dev/null || true)"
count="$(kubectl -n starfleet get deployment ledger -o jsonpath='{.spec.template.spec.containers[*].name}' 2>/dev/null | wc -w | tr -d ' ')"
if [ "$replicas" != "3" ] || [ "$count" != "2" ]; then
  echo "FAIL: the ledger Deployment must keep 3 replicas and 2 containers (found: ${replicas:-none} replicas, $count containers)"
  fail=1
fi
if ! kubectl -n starfleet get deployment fuse >/dev/null 2>&1; then
  echo "FAIL: the fuse Deployment was deleted"
  fail=1
fi
[ "$fail" -eq 0 ] && echo "PASS: the workloads are unchanged"
exit "$fail"
