#!/usr/bin/env bash
# Check: HorizontalPodAutoscaler relay-scaler is served by autoscaling/v2 with its limits and target.
set -uo pipefail

NS=outpost
get() { kubectl -n "$NS" get horizontalpodautoscalers.v2.autoscaling relay-scaler -o jsonpath="$1" 2>/dev/null || true; }

if ! kubectl -n "$NS" get horizontalpodautoscalers.v2.autoscaling relay-scaler >/dev/null 2>&1; then
  echo "FAIL: HorizontalPodAutoscaler relay-scaler not found in autoscaling/v2"
  exit 1
fi

fail=0
[ "$(get '{.spec.scaleTargetRef.name}')" = "relay" ] || { echo "FAIL: scaleTargetRef.name must be relay"; fail=1; }
[ "$(get '{.spec.minReplicas}')" = "2" ] || { echo "FAIL: minReplicas must be 2"; fail=1; }
[ "$(get '{.spec.maxReplicas}')" = "6" ] || { echo "FAIL: maxReplicas must be 6"; fail=1; }
[ "$(get '{.spec.metrics[0].resource.name}')" = "cpu" ] || { echo "FAIL: the metric must be the cpu resource"; fail=1; }
[ "$(get '{.spec.metrics[0].resource.target.type}')" = "Utilization" ] || { echo "FAIL: target.type must be Utilization"; fail=1; }
[ "$(get '{.spec.metrics[0].resource.target.averageUtilization}')" = "60" ] || { echo "FAIL: target.averageUtilization must be 60"; fail=1; }

[ "$fail" -eq 0 ] && echo "PASS: HorizontalPodAutoscaler relay-scaler uses autoscaling/v2"
exit "$fail"
