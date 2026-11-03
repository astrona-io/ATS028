#!/usr/bin/env bash
# Check: fleet-report.restarting-pod names the pod that has restarted.
set -uo pipefail

found="$(kubectl -n starfleet get configmap fleet-report -o jsonpath='{.data.restarting-pod}' 2>/dev/null | tr -d '[:space:]')"
if [ -z "$found" ]; then
  echo "FAIL: fleet-report has no key restarting-pod"
  exit 1
fi
want="$(kubectl -n starfleet get pods -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.status.containerStatuses[0].restartCount}{"\n"}{end}' 2>/dev/null | awk '$2 > 0 {print $1}')"
if ! printf '%s\n' "$want" | grep -qx "$found"; then
  echo "FAIL: restarting-pod is '$found', which is not a pod with a restart count above 0"
  exit 1
fi
echo "PASS: restarting-pod names a pod that has restarted"
