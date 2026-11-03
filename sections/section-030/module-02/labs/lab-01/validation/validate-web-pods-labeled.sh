#!/usr/bin/env bash
# Check: reviewed=true is on the production web pods and on no other pod.
set -uo pipefail

want="$(kubectl -n starfleet get pods -l tier=web,env=prod -o name 2>/dev/null | sort)"
have="$(kubectl -n starfleet get pods -l reviewed=true -o name 2>/dev/null | sort)"

if [ -z "$have" ]; then
  echo "FAIL: no pod carries the label reviewed=true"
  exit 1
fi
if [ "$want" != "$have" ]; then
  echo "FAIL: reviewed=true must be on exactly the tier=web,env=prod pods"
  echo "labeled:"; echo "$have"
  exit 1
fi
echo "PASS: reviewed=true is on exactly the production web pods"
