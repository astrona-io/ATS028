#!/usr/bin/env bash
# Check: CronJob beacon-sweep is served by batch/v1 and keeps its behavior.
set -uo pipefail

NS=outpost
get() { kubectl -n "$NS" get cronjobs.v1.batch beacon-sweep -o jsonpath="$1" 2>/dev/null || true; }

if ! kubectl -n "$NS" get cronjobs.v1.batch beacon-sweep >/dev/null 2>&1; then
  echo "FAIL: CronJob beacon-sweep not found in batch/v1"
  exit 1
fi

fail=0
[ "$(get '{.spec.schedule}')" = "*/15 * * * *" ] || { echo "FAIL: schedule must stay */15 * * * *"; fail=1; }
[ "$(get '{.spec.concurrencyPolicy}')" = "Replace" ] || { echo "FAIL: concurrencyPolicy must stay Replace"; fail=1; }
[ "$(get '{.spec.failedJobsHistoryLimit}')" = "3" ] || { echo "FAIL: failedJobsHistoryLimit must stay 3"; fail=1; }
[ "$(get '{.spec.jobTemplate.spec.template.spec.restartPolicy}')" = "OnFailure" ] || { echo "FAIL: restartPolicy must stay OnFailure"; fail=1; }
[ "$(get '{.spec.jobTemplate.spec.template.spec.containers[0].name}')" = "sweep" ] || { echo "FAIL: the container must be named sweep"; fail=1; }

[ "$fail" -eq 0 ] && echo "PASS: CronJob beacon-sweep is served by batch/v1 with its policy kept"
exit "$fail"
