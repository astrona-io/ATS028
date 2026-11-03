#!/usr/bin/env bash
# Check: both probes exist and point to endpoints that the application serves.
set -uo pipefail

spec="$(kubectl -n starfleet get deployment beacon -o json 2>/dev/null)" || { echo "FAIL: beacon not found"; exit 1; }
c='.spec.template.spec.containers[0]'

rpath="$(jq -r "$c.readinessProbe.httpGet.path // empty" <<<"$spec")"
if [ "$rpath" != "/ready" ] && [ "$rpath" != "/health" ] && [ "$rpath" != "/" ]; then
  echo "FAIL: the readiness probe must be an httpGet on a served path (found: ${rpath:-none})"
  exit 1
fi

lport="$(jq -r "$c.livenessProbe | (.httpGet.port // .tcpSocket.port) // empty" <<<"$spec")"
cport="$(jq -r "$c.ports[0].containerPort" <<<"$spec")"
case "$lport" in
  http|8080) ;;
  *) echo "FAIL: the liveness probe must target the container port 8080 or the port name http (found: ${lport:-none})"; exit 1 ;;
esac
if [ "$cport" != "8080" ]; then
  echo "FAIL: the container port must stay 8080 (found: $cport)"
  exit 1
fi
echo "PASS: both beacon probes exist and target served endpoints"
