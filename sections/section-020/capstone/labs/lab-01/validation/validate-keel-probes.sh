#!/usr/bin/env bash
# Check: keel has a TCP readiness probe and an HTTP liveness probe on /health.
set -uo pipefail

spec="$(kubectl -n starfleet get deployment keel -o json 2>/dev/null)" || { echo "FAIL: Deployment keel not found"; exit 1; }
c='.spec.template.spec.containers[0]'
rport="$(jq -r "$c.readinessProbe.tcpSocket.port // empty" <<<"$spec")"
if [ -z "$rport" ]; then
  echo "FAIL: keel needs a readiness probe that uses tcpSocket"
  exit 1
fi
case "$rport" in http|8080) ;; *) echo "FAIL: the readiness probe must target port 8080 or the name http (found: $rport)"; exit 1 ;; esac
lpath="$(jq -r "$c.livenessProbe.httpGet.path // empty" <<<"$spec")"
lport="$(jq -r "$c.livenessProbe.httpGet.port // empty" <<<"$spec")"
if [ "$lpath" != "/health" ]; then
  echo "FAIL: keel needs a liveness probe that uses httpGet on /health (found: ${lpath:-none})"
  exit 1
fi
case "$lport" in http|8080) ;; *) echo "FAIL: the liveness probe must target port 8080 or the name http (found: $lport)"; exit 1 ;; esac
echo "PASS: keel has a TCP readiness probe and an HTTP liveness probe on /health"
