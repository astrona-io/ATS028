#!/usr/bin/env bash
# Check: the ConfigMap api-audit records the group and version that the API server serves for each kind.
set -uo pipefail

get() { kubectl -n outpost get configmap api-audit -o jsonpath="{.data.$1}" 2>/dev/null | tr -d '[:space:]' || true; }

if ! kubectl -n outpost get configmap api-audit >/dev/null 2>&1; then
  echo "FAIL: ConfigMap api-audit not found in namespace outpost"
  exit 1
fi

fail=0
check() {
  local key="$1" want="$2" found
  found="$(get "$key")"
  if [ "$found" != "$want" ]; then
    echo "FAIL: api-audit key $key must be $want (found: ${found:-nothing})"
    fail=1
  fi
}
check deployment apps/v1
check cronjob batch/v1
check pdb policy/v1
check hpa autoscaling/v2

[ "$fail" -eq 0 ] && echo "PASS: api-audit records the served versions"
exit "$fail"
