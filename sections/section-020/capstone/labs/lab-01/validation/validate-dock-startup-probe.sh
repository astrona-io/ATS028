#!/usr/bin/env bash
# Check: dock has a startup probe with a budget of 60 to 300 seconds and keeps a quick liveness probe.
set -uo pipefail

spec="$(kubectl -n starfleet get deployment dock -o json 2>/dev/null)" || { echo "FAIL: Deployment dock not found"; exit 1; }
sp='.spec.template.spec.containers[0].startupProbe'
lp='.spec.template.spec.containers[0].livenessProbe'
port="$(jq -r "$sp | (.httpGet.port // .tcpSocket.port) // empty" <<<"$spec")"
if [ -z "$port" ]; then
  echo "FAIL: dock has no startupProbe with httpGet or tcpSocket"
  exit 1
fi
case "$port" in http|8080) ;; *) echo "FAIL: the startup probe must target port 8080 or the name http (found: $port)"; exit 1 ;; esac
period="$(jq -r "$sp.periodSeconds // 10" <<<"$spec")"
fails="$(jq -r "$sp.failureThreshold // 3" <<<"$spec")"
delay="$(jq -r "$sp.initialDelaySeconds // 0" <<<"$spec")"
budget=$(( delay + period * fails ))
if [ "$budget" -lt 60 ] || [ "$budget" -gt 300 ]; then
  echo "FAIL: the startup budget is $budget seconds; it must be between 60 and 300"
  exit 1
fi
if [ "$(jq -r "$lp.httpGet.path // empty" <<<"$spec")" = "" ]; then
  echo "FAIL: the liveness probe of dock must stay"
  exit 1
fi
lperiod="$(jq -r "$lp.periodSeconds // 10" <<<"$spec")"
lfails="$(jq -r "$lp.failureThreshold // 3" <<<"$spec")"
if [ "$lperiod" -gt 10 ] || [ "$lfails" -gt 3 ]; then
  echo "FAIL: the liveness probe must keep periodSeconds 10 or less and failureThreshold 3 or less (found: $lperiod and $lfails)"
  exit 1
fi
echo "PASS: dock has a startup budget of $budget seconds and keeps its quick liveness probe"
