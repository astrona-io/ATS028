#!/usr/bin/env bash
# Check: audit-code equals the code that the audit container really prints.
set -uo pipefail

expected="$(kubectl -n starfleet logs deploy/ledger -c audit --tail=60 2>/dev/null | grep -o 'code=E[0-9]*' | head -1 | cut -d= -f2)"
found="$(kubectl -n starfleet get configmap log-findings -o jsonpath='{.data.audit-code}' 2>/dev/null || true)"

if [ -z "$expected" ]; then
  echo "FAIL: the audit container has not printed an error code yet; wait a few seconds and submit again"
  exit 1
fi
if [ "$found" != "$expected" ]; then
  echo "FAIL: log-findings key audit-code must be the code from the audit container (found: ${found:-nothing})"
  exit 1
fi
echo "PASS: audit-code matches the audit container log"
