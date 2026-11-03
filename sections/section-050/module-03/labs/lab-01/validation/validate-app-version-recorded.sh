#!/usr/bin/env bash
# Check: scout-findings key app-version is the APP_VERSION value of the container.
set -uo pipefail

want="$(kubectl -n starfleet get pod scout -o jsonpath='{.spec.containers[?(@.name=="app")].env[?(@.name=="APP_VERSION")].value}' 2>/dev/null)"
val="$(kubectl -n starfleet get configmap scout-findings -o jsonpath='{.data.app-version}' 2>/dev/null | tr -d '[:space:]')"
if [ -z "$val" ]; then
  echo "FAIL: ConfigMap scout-findings in starfleet has no key app-version"
  exit 1
fi
if [ -z "$want" ] || [ "$val" != "$want" ]; then
  echo "FAIL: app-version is '$val', expected the APP_VERSION value of the container"
  exit 1
fi
echo "PASS: app-version matches the container environment"
