#!/usr/bin/env bash
# Check: PodDisruptionBudget relay-budget is served by policy/v1 and selects the relay pods.
set -uo pipefail

NS=outpost
get() { kubectl -n "$NS" get poddisruptionbudgets.v1.policy relay-budget -o jsonpath="$1" 2>/dev/null || true; }

if ! kubectl -n "$NS" get poddisruptionbudgets.v1.policy relay-budget >/dev/null 2>&1; then
  echo "FAIL: PodDisruptionBudget relay-budget not found in policy/v1"
  exit 1
fi

fail=0
[ "$(get '{.spec.maxUnavailable}')" = "1" ] || { echo "FAIL: maxUnavailable must stay 1"; fail=1; }
[ "$(get '{.spec.selector.matchLabels.app}')" = "relay" ] || { echo "FAIL: selector.matchLabels.app must be relay"; fail=1; }

[ "$fail" -eq 0 ] && echo "PASS: PodDisruptionBudget relay-budget uses policy/v1 and selects the relay pods"
exit "$fail"
