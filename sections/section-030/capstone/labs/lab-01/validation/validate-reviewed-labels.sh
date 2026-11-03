#!/usr/bin/env bash
# Check: reviewed=true is on every pod with env=prod and on no other pod.
set -uo pipefail

want="$(kubectl -n starfleet get pods -l env=prod -o name 2>/dev/null | sort)"
found="$(kubectl -n starfleet get pods -l reviewed=true -o name 2>/dev/null | sort)"

if [ -z "$want" ]; then
  echo "FAIL: no pod with env=prod found"
  exit 1
fi
if [ "$found" != "$want" ]; then
  echo "FAIL: reviewed=true must be on exactly the pods with env=prod"
  echo "pods with env=prod: $(printf '%s ' $want)"
  echo "pods with reviewed=true: $(printf '%s ' $found)"
  exit 1
fi
echo "PASS: reviewed=true is on exactly the env=prod pods"
