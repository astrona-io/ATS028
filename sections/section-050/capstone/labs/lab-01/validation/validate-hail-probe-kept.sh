#!/usr/bin/env bash
# Check: hail still has an HTTP readiness probe.
set -uo pipefail

path="$(kubectl -n starfleet get deployment hail -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.path}' 2>/dev/null)"
if [ -z "$path" ]; then
  echo "FAIL: hail has no HTTP readiness probe; correct the probe, do not remove it"
  exit 1
fi
echo "PASS: hail keeps its HTTP readiness probe on $path"
