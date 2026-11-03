#!/usr/bin/env bash
# Check: Deployment relay is served by apps/v1 with an explicit selector and keeps its behavior.
set -uo pipefail

NS=outpost
get() { kubectl -n "$NS" get deployments.v1.apps relay -o jsonpath="$1" 2>/dev/null || true; }

if ! kubectl -n "$NS" get deployments.v1.apps relay >/dev/null 2>&1; then
  echo "FAIL: Deployment relay not found in apps/v1"
  exit 1
fi

fail=0
[ "$(get '{.spec.selector.matchLabels.app}')" = "relay" ] || { echo "FAIL: spec.selector.matchLabels.app must be relay"; fail=1; }
[ "$(get '{.spec.template.metadata.labels.app}')" = "relay" ] || { echo "FAIL: the pod template label app must be relay"; fail=1; }
[ "$(get '{.spec.replicas}')" = "2" ] || { echo "FAIL: replicas must stay 2"; fail=1; }
[ "$(get '{.spec.template.spec.containers[0].image}')" = "docker.io/library/python:3.13-alpine" ] || { echo "FAIL: the image must stay docker.io/library/python:3.13-alpine"; fail=1; }
[ "$(get '{.spec.template.spec.containers[0].readinessProbe.httpGet.path}')" = "/ready" ] || { echo "FAIL: the readiness probe path must stay /ready"; fail=1; }
[ "$(get '{.spec.template.spec.volumes[0].configMap.name}')" = "probe-code" ] || { echo "FAIL: the pods must mount the ConfigMap probe-code"; fail=1; }
if [ "$fail" -eq 0 ] && [ "$(get '{.status.readyReplicas}')" != "2" ]; then
  echo "FAIL: the Deployment must have 2 ready replicas (found: $(get '{.status.readyReplicas}'))"
  fail=1
fi

[ "$fail" -eq 0 ] && echo "PASS: Deployment relay is served by apps/v1 and has 2 ready replicas"
exit "$fail"
