#!/usr/bin/env bash
# Check: rollout-report.reason holds an image pull waiting reason.
set -uo pipefail

reason="$(kubectl -n starfleet get configmap rollout-report -o jsonpath='{.data.reason}' 2>/dev/null | tr -d '[:space:]')"
case "$reason" in
  ErrImagePull|ImagePullBackOff)
    echo "PASS: reason is $reason"
    ;;
  "")
    echo "FAIL: ConfigMap rollout-report in starfleet has no key reason"
    exit 1
    ;;
  *)
    echo "FAIL: reason is '$reason'; expected ErrImagePull or ImagePullBackOff"
    exit 1
    ;;
esac
