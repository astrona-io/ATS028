#!/usr/bin/env bash
# Check: keel has 1 ready replica, no restarts, and its pod carries the new probes.
set -uo pipefail

ready="$(kubectl -n starfleet get deployment keel -o jsonpath='{.status.readyReplicas}' 2>/dev/null || true)"
if [ "$ready" != "1" ]; then
  echo "FAIL: keel must have 1 ready replica (found: ${ready:-none})"
  exit 1
fi
pod_probe="$(kubectl -n starfleet get pods -l app=keel -o jsonpath='{.items[0].spec.containers[0].livenessProbe.httpGet.path}' 2>/dev/null || true)"
if [ "$pod_probe" != "/health" ]; then
  echo "FAIL: the running keel pod does not have the new liveness probe yet; wait for the rollout to finish"
  exit 1
fi
restarts="$(kubectl -n starfleet get pods -l app=keel -o json | jq '[.items[].status.containerStatuses[0].restartCount] | add')"
if [ "${restarts:-1}" != "0" ]; then
  echo "FAIL: the keel container restarted $restarts times"
  exit 1
fi
echo "PASS: keel is ready with its new probes and no restarts"
