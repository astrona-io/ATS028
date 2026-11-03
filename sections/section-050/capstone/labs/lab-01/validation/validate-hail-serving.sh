#!/usr/bin/env bash
# Check: hail has 2 ready replicas and answers through its Service.
set -uo pipefail

ready="$(kubectl -n starfleet get deployment hail -o jsonpath='{.status.readyReplicas}' 2>/dev/null)"
if [ "${ready:-0}" != "2" ]; then
  echo "FAIL: deployment hail has ${ready:-0} ready replicas, expected 2"
  exit 1
fi
for i in 1 2 3 4 5; do
  if kubectl -n starfleet exec shuttle -- wget -q -O /dev/null -T 3 http://hail 2>/dev/null; then
    echo "PASS: hail is ready and answers through its Service"
    exit 0
  fi
  sleep 2
done
echo "FAIL: request from shuttle to http://hail failed"
exit 1
