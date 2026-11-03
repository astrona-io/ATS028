#!/usr/bin/env bash
# Check: PodDisruptionBudget probe-budget is stored in policy/v1 and selects
# the probe pods explicitly.
set -uo pipefail

NS=starfleet
get() {
  kubectl -n "$NS" get poddisruptionbudgets.v1.policy probe-budget -o jsonpath="$1" 2>/dev/null || true
}

if ! kubectl -n "$NS" get poddisruptionbudgets.v1.policy probe-budget >/dev/null 2>&1; then
  echo "FAIL: PodDisruptionBudget probe-budget not found in policy/v1"
  exit 1
fi

fail=0
[ "$(get '{.spec.minAvailable}')" = "1" ] || { echo "FAIL: minAvailable must stay 1"; fail=1; }
[ "$(get '{.spec.selector.matchLabels.app}')" = "probe" ] || { echo "FAIL: selector.matchLabels.app must be probe"; fail=1; }

[ "$fail" -eq 0 ] && echo "PASS: PodDisruptionBudget probe-budget uses policy/v1 and selects the probe pods"
exit "$fail"
