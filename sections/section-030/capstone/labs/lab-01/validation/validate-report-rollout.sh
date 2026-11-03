#!/usr/bin/env bash
# Check: fleet-report records the failed image and the waiting reason of dock.
set -uo pipefail

current="$(kubectl -n starfleet get deployment dock -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null || true)"
failed="$(kubectl -n starfleet get replicasets -l app=dock -o jsonpath='{range .items[*]}{.spec.template.spec.containers[0].image}{"\n"}{end}' 2>/dev/null | grep -vx "$current" | sort -u)"
image="$(kubectl -n starfleet get configmap fleet-report -o jsonpath='{.data.failed-image}' 2>/dev/null | tr -d '[:space:]')"
reason="$(kubectl -n starfleet get configmap fleet-report -o jsonpath='{.data.reason}' 2>/dev/null | tr -d '[:space:]')"

if [ -z "$failed" ]; then
  echo "FAIL: no ReplicaSet of dock with another image exists; the revision history was deleted"
  exit 1
fi
if [ "$image" != "$failed" ]; then
  echo "FAIL: failed-image is '${image:-nothing}', the failed revision used '$failed'"
  exit 1
fi
case "$reason" in
  ErrImagePull|ImagePullBackOff) ;;
  *)
    echo "FAIL: reason is '${reason:-nothing}'; expected ErrImagePull or ImagePullBackOff"
    exit 1
    ;;
esac
echo "PASS: fleet-report records the failed image and the reason $reason"
