#!/usr/bin/env bash
# Check: api-findings holds the group and version that the API server serves
# as preferred for each resource. It first confirms that the cluster serves
# each expected group and version, then compares the recorded values.
set -uo pipefail

fail=0

check_key() {
  local key="$1" expected="$2" found
  found="$(kubectl -n starfleet get configmap api-findings -o jsonpath="{.data.$key}" 2>/dev/null || true)"
  if [ "$found" != "$expected" ]; then
    echo "FAIL: api-findings key $key must be $expected (found: ${found:-nothing})"
    fail=1
  fi
}

served() {
  kubectl api-versions | grep -qx "$1"
}

for group_version in rbac.authorization.k8s.io/v1 scheduling.k8s.io/v1 networking.k8s.io/v1; do
  if ! served "$group_version"; then
    echo "FAIL: the cluster does not serve $group_version, so the lab expectation is wrong"
    fail=1
  fi
done

check_key role rbac.authorization.k8s.io/v1
check_key priorityclass scheduling.k8s.io/v1
check_key ingress networking.k8s.io/v1

if [ "$fail" -eq 0 ]; then
  echo "PASS: api-findings records the supported group and version of each resource"
fi
exit "$fail"
