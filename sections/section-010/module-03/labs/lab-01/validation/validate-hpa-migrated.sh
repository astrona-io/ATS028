#!/usr/bin/env bash
# Check: HorizontalPodAutoscaler probe-scaler reads in autoscaling/v2 with a
# Utilization target of 55 percent CPU.
set -uo pipefail

NS=starfleet
get() {
  kubectl -n "$NS" get horizontalpodautoscalers.v2.autoscaling probe-scaler -o jsonpath="$1" 2>/dev/null || true
}

if ! kubectl -n "$NS" get horizontalpodautoscalers.v2.autoscaling probe-scaler >/dev/null 2>&1; then
  echo "FAIL: HorizontalPodAutoscaler probe-scaler not found in autoscaling/v2"
  exit 1
fi

fail=0
[ "$(get '{.spec.scaleTargetRef.name}')" = "probe" ] || { echo "FAIL: scaleTargetRef.name must be probe"; fail=1; }
[ "$(get '{.spec.minReplicas}')" = "2" ] || { echo "FAIL: minReplicas must be 2"; fail=1; }
[ "$(get '{.spec.maxReplicas}')" = "5" ] || { echo "FAIL: maxReplicas must be 5"; fail=1; }
[ "$(get '{.spec.metrics[0].resource.name}')" = "cpu" ] || { echo "FAIL: the metric must be the cpu resource"; fail=1; }
[ "$(get '{.spec.metrics[0].resource.target.type}')" = "Utilization" ] || { echo "FAIL: target.type must be Utilization"; fail=1; }
[ "$(get '{.spec.metrics[0].resource.target.averageUtilization}')" = "55" ] || { echo "FAIL: target.averageUtilization must be 55"; fail=1; }

[ "$fail" -eq 0 ] && echo "PASS: HorizontalPodAutoscaler probe-scaler uses autoscaling/v2"
exit "$fail"
