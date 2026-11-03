#!/usr/bin/env bash
# Check: capstone-report names the causes of the hail and dock faults.
set -uo pipefail

hail="$(kubectl -n starfleet get configmap capstone-report -o jsonpath='{.data.hail}' 2>/dev/null)"
dock="$(kubectl -n starfleet get configmap capstone-report -o jsonpath='{.data.dock}' 2>/dev/null)"
fail=0
if ! printf '%s' "$hail" | grep -Eqi 'Unhealthy|Readiness probe failed|connection refused'; then
  echo "FAIL: key hail is '${hail}', expected the event reason of the failing readiness probe"
  fail=1
fi
if ! printf '%s' "$dock" | grep -Eqi 'ImagePullBackOff|ErrImagePull'; then
  echo "FAIL: key dock is '${dock}', expected the image pull reason"
  fail=1
fi
if [ "$fail" -ne 0 ]; then exit 1; fi
echo "PASS: causes recorded"
