#!/usr/bin/env bash
# Check: findings.images lists each distinct container image of starfleet once.
set -uo pipefail

norm() { tr ' ,' '\n\n' | sed '/^$/d' | sort -u; }

expected="$(kubectl -n starfleet get pods -o jsonpath='{range .items[*]}{range .spec.containers[*]}{.image}{"\n"}{end}{end}' 2>/dev/null | norm)"
recorded="$(kubectl -n starfleet get configmap findings -o jsonpath='{.data.images}' 2>/dev/null | norm)"

if [ -z "$recorded" ]; then
  echo "FAIL: ConfigMap findings in starfleet has no key images"
  exit 1
fi
if [ "$expected" != "$recorded" ]; then
  echo "FAIL: images does not match the distinct images of the pods in starfleet"
  echo "expected:"; echo "$expected"
  echo "recorded:"; echo "$recorded"
  exit 1
fi
echo "PASS: images lists the distinct container images"
