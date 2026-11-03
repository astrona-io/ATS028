#!/usr/bin/env bash
# Check: the recorded budget equals the live startup probe budget.
set -uo pipefail

val="$(kubectl -n starfleet get configmap probe-budget -o jsonpath='{.data.startup-seconds}' 2>/dev/null || true)"
if [ -z "$val" ]; then
  echo "FAIL: ConfigMap probe-budget with key startup-seconds not found in starfleet"
  exit 1
fi
sp='.spec.template.spec.containers[0].startupProbe'
spec="$(kubectl -n starfleet get deployment beacon -o json)"
period="$(jq -r "$sp.periodSeconds // 10" <<<"$spec")"
fails="$(jq -r "$sp.failureThreshold // 3" <<<"$spec")"
delay="$(jq -r "$sp.initialDelaySeconds // 0" <<<"$spec")"
want=$(( delay + period * fails ))
if [ "$val" != "$want" ]; then
  echo "FAIL: startup-seconds is $val but the live budget is $want"
  exit 1
fi
echo "PASS: probe-budget records $val seconds"
