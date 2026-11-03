#!/usr/bin/env bash
# Check: rollout-report.failed-image is the image of the old, failed revision.
set -uo pipefail

current="$(kubectl -n starfleet get deployment beacon -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null || true)"
failed="$(kubectl -n starfleet get replicasets -l app=beacon -o jsonpath='{range .items[*]}{.spec.template.spec.containers[0].image}{"\n"}{end}' 2>/dev/null | grep -vx "$current" | sort -u)"
recorded="$(kubectl -n starfleet get configmap rollout-report -o jsonpath='{.data.failed-image}' 2>/dev/null | tr -d '[:space:]')"

if [ -z "$failed" ]; then
  echo "FAIL: no ReplicaSet of beacon with another image exists; the revision history was deleted"
  exit 1
fi
if [ -z "$recorded" ]; then
  echo "FAIL: ConfigMap rollout-report in starfleet has no key failed-image"
  exit 1
fi
if [ "$recorded" != "$failed" ]; then
  echo "FAIL: failed-image is '$recorded', the failed revision used '$failed'"
  exit 1
fi
echo "PASS: failed-image names the image of the failed revision"
