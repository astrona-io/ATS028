#!/usr/bin/env bash
# Check: the probe Deployment is still revision 1 and serving.
set -uo pipefail

rev="$(kubectl -n starfleet get deployment probe -o jsonpath='{.metadata.annotations.deployment\.kubernetes\.io/revision}' 2>/dev/null || true)"
if [ "$rev" != "1" ]; then
  echo "FAIL: probe is at revision ${rev:-none}; it must stay at revision 1"
  exit 1
fi
if ! kubectl -n starfleet exec shuttle -- wget -q -T 3 -O- http://probe/ 2>/dev/null | grep -q 'version=v1'; then
  echo "FAIL: shuttle did not receive version=v1 from the probe Service"
  exit 1
fi
echo "PASS: probe is untouched and serving"
