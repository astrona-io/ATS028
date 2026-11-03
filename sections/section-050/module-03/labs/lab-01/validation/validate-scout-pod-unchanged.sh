#!/usr/bin/env bash
# Check: scout is the original pod, running, with no container restart.
set -uo pipefail

want="$(kubectl -n default get configmap lab-baseline -o jsonpath='{.data.scout-uid}' 2>/dev/null)"
have="$(kubectl -n starfleet get pod scout -o jsonpath='{.metadata.uid}' 2>/dev/null)"
if [ -z "$have" ]; then
  echo "FAIL: pod scout does not exist"
  exit 1
fi
if [ -z "$want" ] || [ "$want" != "$have" ]; then
  echo "FAIL: pod scout was deleted and created again; fix the Service and keep the pod"
  exit 1
fi
phase="$(kubectl -n starfleet get pod scout -o jsonpath='{.status.phase}' 2>/dev/null)"
restarts="$(kubectl -n starfleet get pod scout -o jsonpath='{.status.containerStatuses[?(@.name=="app")].restartCount}' 2>/dev/null)"
if [ "$phase" != "Running" ] || [ "${restarts:-0}" != "0" ]; then
  echo "FAIL: pod scout must be Running with 0 restarts (phase: ${phase:-none}, restarts: ${restarts:-?})"
  exit 1
fi
echo "PASS: pod scout is the original pod and is running"
