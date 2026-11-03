#!/usr/bin/env bash
# Check: the PriorityClass keeps its value and is not the global default.
set -uo pipefail

value="$(kubectl get priorityclasses.v1.scheduling.k8s.io fleet-critical -o jsonpath='{.value}' 2>/dev/null || true)"
default="$(kubectl get priorityclasses.v1.scheduling.k8s.io fleet-critical -o jsonpath='{.globalDefault}' 2>/dev/null || true)"

if [ "$value" != "900000" ]; then
  echo "FAIL: the PriorityClass fleet-critical must exist with value 900000 (found: ${value:-nothing})"
  exit 1
fi
if [ "$default" = "true" ]; then
  echo "FAIL: fleet-critical must not be the global default"
  exit 1
fi
echo "PASS: fleet-critical has value 900000 and is not the global default"
