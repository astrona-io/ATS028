#!/usr/bin/env bash
# Check: cadet is ready and still takes MODE from ConfigMap cadet-settings.
set -uo pipefail

ref="$(kubectl -n starfleet get deployment cadet -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="MODE")].valueFrom.configMapKeyRef.name}' 2>/dev/null)"
if [ "$ref" != "cadet-settings" ]; then
  echo "FAIL: cadet must keep reading MODE from the ConfigMap cadet-settings (found: ${ref:-none})"
  exit 1
fi
mode="$(kubectl -n starfleet get configmap cadet-settings -o jsonpath='{.data.mode}' 2>/dev/null)"
if [ -z "$mode" ]; then
  echo "FAIL: ConfigMap cadet-settings has no key mode"
  exit 1
fi
ready="$(kubectl -n starfleet get deployment cadet -o jsonpath='{.status.readyReplicas}' 2>/dev/null)"
if [ "${ready:-0}" != "1" ]; then
  echo "FAIL: deployment cadet has ${ready:-0} ready replicas, expected 1"
  exit 1
fi
echo "PASS: cadet is ready and reads cadet-settings"
