#!/usr/bin/env bash
# Check: valve-key equals the variable named in the valve pod log.
set -uo pipefail

logs="$(kubectl -n starfleet logs -l app=valve -c app --previous 2>/dev/null || kubectl -n starfleet logs -l app=valve -c app 2>/dev/null || true)"
expected="$(printf '%s\n' "$logs" | grep -o 'VALVE_KEY_[0-9]*' | head -1)"
found="$(kubectl -n starfleet get configmap log-report -o jsonpath='{.data.valve-key}' 2>/dev/null || true)"

if [ -z "$expected" ]; then
  echo "FAIL: the valve pod has no log yet; wait a few seconds and submit again"
  exit 1
fi
if [ "$found" != "$expected" ]; then
  echo "FAIL: log-report key valve-key must be the variable named in the valve log (found: ${found:-nothing})"
  exit 1
fi
echo "PASS: valve-key matches the valve log"
