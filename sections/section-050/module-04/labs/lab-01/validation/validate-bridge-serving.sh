#!/usr/bin/env bash
# Check: a request from shuttle through the Service bridge returns bridge-ok.
set -uo pipefail

for i in 1 2 3 4 5; do
  out="$(kubectl -n starfleet exec shuttle -- wget -qO- -T 3 http://bridge 2>/dev/null || true)"
  if printf '%s' "$out" | grep -q 'bridge-ok'; then
    echo "PASS: http://bridge returned bridge-ok"
    exit 0
  fi
  sleep 2
done
echo "FAIL: http://bridge did not return bridge-ok; compare the Service selector with the pod labels"
exit 1
