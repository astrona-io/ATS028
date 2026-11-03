#!/usr/bin/env bash
# Check: the legacy files and the application code are still in place.
set -uo pipefail

fail=0
for key in 'deployment\.yaml' 'cronjob\.yaml' 'pdb\.yaml' 'hpa\.yaml'; do
  value="$(kubectl -n outpost get configmap legacy-bundle -o jsonpath="{.data.$key}" 2>/dev/null || true)"
  if [ -z "$value" ]; then
    echo "FAIL: the ConfigMap legacy-bundle must keep the key ${key//\\/}"
    fail=1
  fi
done
if ! kubectl -n outpost get configmap probe-code >/dev/null 2>&1; then
  echo "FAIL: the ConfigMap probe-code must not be deleted"
  fail=1
fi
[ "$fail" -eq 0 ] && echo "PASS: legacy-bundle and probe-code are unchanged"
exit "$fail"
