#!/usr/bin/env bash
# Check: shuttle gets an answer from the hail, dock and keel Services.
set -uo pipefail

for svc in hail dock keel; do
  if ! kubectl -n starfleet exec shuttle -- wget -q -T 3 -O- "http://$svc/" 2>/dev/null | grep -q 'version=v1'; then
    echo "FAIL: shuttle did not receive version=v1 from the $svc Service"
    exit 1
  fi
done
echo "PASS: the hail, dock and keel Services answer"
