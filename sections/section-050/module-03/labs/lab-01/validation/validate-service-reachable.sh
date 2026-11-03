#!/usr/bin/env bash
# Check: a request from shuttle to the Service scout succeeds.
set -uo pipefail

for i in 1 2 3 4 5; do
  if kubectl -n starfleet exec shuttle -- wget -q -O /dev/null -T 3 http://scout 2>/dev/null; then
    echo "PASS: request from shuttle to http://scout succeeded"
    exit 0
  fi
  sleep 2
done
echo "FAIL: request from shuttle to http://scout failed; compare the Service targetPort with the listening port"
exit 1
