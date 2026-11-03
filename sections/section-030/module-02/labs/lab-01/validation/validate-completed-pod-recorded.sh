#!/usr/bin/env bash
# Check: findings.completed-pod names the pod whose phase is Succeeded.
set -uo pipefail

expected="$(kubectl -n starfleet get pods --field-selector=status.phase=Succeeded -o name 2>/dev/null | sed 's|^pod/||' | head -n1)"
recorded="$(kubectl -n starfleet get configmap findings -o jsonpath='{.data.completed-pod}' 2>/dev/null | tr -d '[:space:]' | sed 's|^pod/||')"

if [ -z "$expected" ]; then
  echo "FAIL: no pod in phase Succeeded; the Job was deleted"
  exit 1
fi
if [ "$recorded" != "$expected" ]; then
  echo "FAIL: completed-pod is '${recorded:-empty}', the finished pod is '$expected'"
  exit 1
fi
echo "PASS: completed-pod names the finished pod"
