#!/usr/bin/env bash
# Check: log-report keys pods and containers match the manifest Deployment.
set -uo pipefail

want_pods="$(kubectl -n starfleet get pods -l app=manifest -o name 2>/dev/null | wc -l | tr -d ' ')"
want_containers="$(kubectl -n starfleet get deployment manifest -o jsonpath='{range .spec.template.spec.containers[*]}{.name}{"\n"}{end}' 2>/dev/null | sort | paste -sd, -)"
pods="$(kubectl -n starfleet get configmap log-report -o jsonpath='{.data.pods}' 2>/dev/null | tr -d '[:space:]')"
containers="$(kubectl -n starfleet get configmap log-report -o jsonpath='{.data.containers}' 2>/dev/null | tr -d '[:space:]')"

if [ "$pods" != "$want_pods" ]; then
  echo "FAIL: log-report key pods is '${pods}', expected $want_pods"
  exit 1
fi
if [ "$containers" != "$want_containers" ]; then
  echo "FAIL: log-report key containers is '${containers}', expected $want_containers"
  exit 1
fi
echo "PASS: pods and containers are correct"
