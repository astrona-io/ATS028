#!/usr/bin/env bash
# Check: scout-reader has read rights only. Rejects a wildcard Role and a
# binding to a broad built-in role.
set -uo pipefail

SA="system:serviceaccount:starfleet:scout-reader"
fail=0

expect_no() {
  local description="$1"
  shift
  local answer
  answer="$(kubectl auth can-i "$@" --as="$SA" 2>/dev/null || true)"
  if [ "$answer" != "no" ]; then
    echo "FAIL: scout-reader is allowed to $description"
    fail=1
  fi
}

expect_no "delete pods in starfleet" delete pods -n starfleet
expect_no "create pods in starfleet" create pods -n starfleet
expect_no "read secrets in starfleet" get secrets -n starfleet
expect_no "list pods in outpost" list pods -n outpost
expect_no "do anything in starfleet" '*' '*' -n starfleet

if [ "$fail" -eq 0 ]; then
  echo "PASS: scout-reader has read rights in starfleet only"
fi
exit "$fail"
