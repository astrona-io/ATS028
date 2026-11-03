#!/usr/bin/env bash
# Check: probe-report records the port that failed on hail and the startup budget that dock uses.
set -uo pipefail

get() { kubectl -n starfleet get configmap probe-report -o jsonpath="{.data.$1}" 2>/dev/null | tr -d '[:space:]' || true; }

if ! kubectl -n starfleet get configmap probe-report >/dev/null 2>&1; then
  echo "FAIL: ConfigMap probe-report not found in namespace starfleet"
  exit 1
fi
port="$(get hail-wrong-port)"
if [ "$port" != "8081" ]; then
  echo "FAIL: probe-report key hail-wrong-port must be the port from the failing probe event (found: ${port:-nothing})"
  exit 1
fi
spec="$(kubectl -n starfleet get deployment dock -o json 2>/dev/null || true)"
sp='.spec.template.spec.containers[0].startupProbe'
period="$(jq -r "$sp.periodSeconds // 10" <<<"$spec" 2>/dev/null || echo 10)"
fails="$(jq -r "$sp.failureThreshold // 3" <<<"$spec" 2>/dev/null || echo 3)"
delay="$(jq -r "$sp.initialDelaySeconds // 0" <<<"$spec" 2>/dev/null || echo 0)"
budget=$(( delay + period * fails ))
seconds="$(get dock-startup-seconds)"
if [ "$seconds" != "$budget" ]; then
  echo "FAIL: probe-report key dock-startup-seconds is '${seconds}', but the startup probe of dock gives $budget seconds"
  exit 1
fi
echo "PASS: probe-report records port 8081 and a startup budget of $budget seconds"
