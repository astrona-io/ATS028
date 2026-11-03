#!/usr/bin/env bash
# Check: liveness probe is kept and still reacts quickly.
set -uo pipefail

spec="$(kubectl -n starfleet get deployment beacon -o json 2>/dev/null)" || { echo "FAIL: beacon not found"; exit 1; }
lp='.spec.template.spec.containers[0].livenessProbe'
if [ "$(jq -r "$lp | type" <<<"$spec")" != "object" ]; then
  echo "FAIL: the liveness probe was removed"
  exit 1
fi
period="$(jq -r "$lp.periodSeconds // 10" <<<"$spec")"
fails="$(jq -r "$lp.failureThreshold // 3" <<<"$spec")"
if [ "$period" -gt 10 ] || [ "$fails" -gt 3 ]; then
  echo "FAIL: liveness must stay fast (period $period, failureThreshold $fails)"
  exit 1
fi
echo "PASS: liveness kept with period $period and failureThreshold $fails"
