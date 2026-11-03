#!/usr/bin/env bash
# Check: findings.web-pods lists exactly the pods with tier=web and env=prod.
set -uo pipefail

norm() { tr ' ,' '\n\n' | sed 's|^pod/||' | sed '/^$/d' | sort -u; }

expected="$(kubectl -n starfleet get pods -l tier=web,env=prod -o name 2>/dev/null | norm)"
recorded="$(kubectl -n starfleet get configmap findings -o jsonpath='{.data.web-pods}' 2>/dev/null | norm)"

if [ -z "$expected" ]; then
  echo "FAIL: no pods match tier=web,env=prod; the Deployments were changed"
  exit 1
fi
if [ -z "$recorded" ]; then
  echo "FAIL: ConfigMap findings in starfleet has no key web-pods"
  exit 1
fi
if [ "$expected" != "$recorded" ]; then
  echo "FAIL: web-pods does not match the pods selected by tier=web,env=prod"
  echo "expected:"; echo "$expected"
  echo "recorded:"; echo "$recorded"
  exit 1
fi
echo "PASS: web-pods lists the production web pods"
