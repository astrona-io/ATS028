#!/usr/bin/env bash
# Check: the application was not disturbed by the reporting work.
set -uo pipefail

ready="$(kubectl -n starfleet get deployment probe -o jsonpath='{.status.readyReplicas}' 2>/dev/null || true)"
if [ "$ready" != "2" ]; then
  echo "FAIL: the probe Deployment must have 2 ready replicas (found: ${ready:-none})"
  exit 1
fi
if ! kubectl -n starfleet exec shuttle -- wget -q -T 3 -O- http://probe/ 2>/dev/null | grep -q 'version=v1'; then
  echo "FAIL: shuttle did not receive version=v1 from the probe Service"
  exit 1
fi
echo "PASS: the probe application still answers through its Service"
