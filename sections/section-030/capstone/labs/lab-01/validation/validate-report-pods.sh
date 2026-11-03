#!/usr/bin/env bash
# Check: fleet-report.prod-web-pods lists exactly the pods with tier=web and env=prod.
set -uo pipefail

want="$(kubectl -n starfleet get pods -l tier=web,env=prod -o name 2>/dev/null | sed 's#^pod/##' | sort)"
found="$(kubectl -n starfleet get configmap fleet-report -o jsonpath='{.data.prod-web-pods}' 2>/dev/null | tr -s '[:space:]' '\n' | sed '/^$/d' | sort)"

if ! kubectl -n starfleet get configmap fleet-report >/dev/null 2>&1; then
  echo "FAIL: ConfigMap fleet-report not found in namespace starfleet"
  exit 1
fi
if [ -z "$found" ]; then
  echo "FAIL: fleet-report has no key prod-web-pods"
  exit 1
fi
if [ "$found" != "$want" ]; then
  echo "FAIL: prod-web-pods must list exactly the pods with tier=web and env=prod, one name per line"
  exit 1
fi
echo "PASS: prod-web-pods lists the pods with tier=web and env=prod"
