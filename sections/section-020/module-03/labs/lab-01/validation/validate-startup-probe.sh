#!/usr/bin/env bash
# Check: beacon has a startup probe with a budget between 60 and 300 seconds.
set -uo pipefail

spec="$(kubectl -n starfleet get deployment beacon -o json 2>/dev/null)" || { echo "FAIL: beacon not found"; exit 1; }
sp='.spec.template.spec.containers[0].startupProbe'
port="$(jq -r "$sp | (.httpGet.port // .tcpSocket.port) // empty" <<<"$spec")"
if [ -z "$port" ]; then
  echo "FAIL: beacon has no startupProbe with httpGet or tcpSocket"
  exit 1
fi
case "$port" in http|8080) ;; *) echo "FAIL: the startup probe must target port 8080 or the name http (found: $port)"; exit 1 ;;
esac
period="$(jq -r "$sp.periodSeconds // 10" <<<"$spec")"
fails="$(jq -r "$sp.failureThreshold // 3" <<<"$spec")"
delay="$(jq -r "$sp.initialDelaySeconds // 0" <<<"$spec")"
budget=$(( delay + period * fails ))
if [ "$budget" -lt 60 ] || [ "$budget" -gt 300 ]; then
  echo "FAIL: the startup budget is $budget seconds; it must be between 60 and 300"
  exit 1
fi
echo "PASS: startup probe budget is $budget seconds"
