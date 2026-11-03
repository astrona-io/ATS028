#!/usr/bin/env bash
# Check: CronJob shuttle-sweep is stored in batch/v1 and keeps its behavior.
set -uo pipefail

NS=starfleet
get() {
  kubectl -n "$NS" get cronjobs.v1.batch shuttle-sweep -o jsonpath="$1" 2>/dev/null || true
}

if ! kubectl -n "$NS" get cronjobs.v1.batch shuttle-sweep >/dev/null 2>&1; then
  echo "FAIL: CronJob shuttle-sweep not found in batch/v1"
  exit 1
fi

fail=0
[ "$(get '{.spec.schedule}')" = "*/10 * * * *" ] || { echo "FAIL: schedule must stay */10 * * * *"; fail=1; }
[ "$(get '{.spec.concurrencyPolicy}')" = "Forbid" ] || { echo "FAIL: concurrencyPolicy must stay Forbid"; fail=1; }
[ "$(get '{.spec.successfulJobsHistoryLimit}')" = "2" ] || { echo "FAIL: successfulJobsHistoryLimit must stay 2"; fail=1; }
[ "$(get '{.spec.jobTemplate.spec.template.spec.restartPolicy}')" = "Never" ] || { echo "FAIL: restartPolicy must stay Never"; fail=1; }
[ "$(get '{.spec.jobTemplate.spec.template.spec.containers[0].name}')" = "sweep" ] || { echo "FAIL: container must be named sweep"; fail=1; }

[ "$fail" -eq 0 ] && echo "PASS: CronJob shuttle-sweep is served by batch/v1 with its policy kept"
exit "$fail"
