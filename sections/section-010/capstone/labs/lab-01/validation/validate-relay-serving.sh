#!/usr/bin/env bash
# Check: the relay Service has two ready endpoints and the drifter pod gets an answer through it.
set -uo pipefail

ready="$(kubectl -n outpost get endpointslices -l kubernetes.io/service-name=relay -o jsonpath='{.items[*].endpoints[*].conditions.ready}' 2>/dev/null || true)"
count="$(printf '%s\n' "$ready" | tr ' ' '\n' | grep -c '^true$' || true)"
if [ "$count" != "2" ]; then
  echo "FAIL: the relay Service must have 2 ready endpoints (found: $count)"
  exit 1
fi
if ! kubectl -n outpost exec drifter -- wget -q -T 3 -O- http://relay/ 2>/dev/null | grep -q 'version=v1'; then
  echo "FAIL: drifter did not receive version=v1 from the relay Service"
  exit 1
fi
echo "PASS: the relay Service answers through its 2 ready endpoints"
