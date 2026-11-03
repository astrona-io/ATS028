#!/usr/bin/env bash
# Check: hail keeps an HTTP readiness probe, now on the port the application listens on, and has 2 ready replicas.
set -uo pipefail

rp='.spec.template.spec.containers[0].readinessProbe'
spec="$(kubectl -n starfleet get deployment hail -o json 2>/dev/null)" || { echo "FAIL: Deployment hail not found"; exit 1; }
port="$(jq -r "$rp.httpGet.port // empty" <<<"$spec")"
path="$(jq -r "$rp.httpGet.path // empty" <<<"$spec")"
if [ -z "$port" ]; then
  echo "FAIL: hail must keep an HTTP readiness probe (httpGet)"
  exit 1
fi
case "$port" in http|8080) ;; *) echo "FAIL: the readiness probe of hail must use the port http or 8080 (found: $port)"; exit 1 ;; esac
case "$path" in /|/ready|/health) ;; *) echo "FAIL: the readiness probe path must be a path the application serves: / or /ready or /health (found: $path)"; exit 1 ;; esac
ready="$(kubectl -n starfleet get deployment hail -o jsonpath='{.status.readyReplicas}' 2>/dev/null || true)"
if [ "$ready" != "2" ]; then
  echo "FAIL: hail must have 2 ready replicas (found: ${ready:-none})"
  exit 1
fi
echo "PASS: hail has 2 ready replicas with its readiness probe on port $port"
