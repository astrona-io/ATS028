#!/usr/bin/env bash
# Check: capstone-report has beacon-build (the BUILD_ID) and beacon-port (9191).
set -uo pipefail

want="$(kubectl -n starfleet get pod beacon -o jsonpath='{.spec.containers[?(@.name=="app")].env[?(@.name=="BUILD_ID")].value}' 2>/dev/null)"
build="$(kubectl -n starfleet get configmap capstone-report -o jsonpath='{.data.beacon-build}' 2>/dev/null | tr -d '[:space:]')"
port="$(kubectl -n starfleet get configmap capstone-report -o jsonpath='{.data.beacon-port}' 2>/dev/null | tr -d '[:space:]')"
if [ -z "$want" ] || [ "$build" != "$want" ]; then
  echo "FAIL: beacon-build is '${build}', expected the BUILD_ID of the container"
  exit 1
fi
if [ "$port" != "9191" ]; then
  echo "FAIL: beacon-port is '${port}', expected the port the process listens on"
  exit 1
fi
echo "PASS: beacon-build and beacon-port are correct"
