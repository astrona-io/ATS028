#!/usr/bin/env bash
# Check: triage-report names the cause of each fault.
set -uo pipefail

get() { kubectl -n starfleet get configmap triage-report -o "jsonpath={.data.$1}" 2>/dev/null; }

if ! kubectl -n starfleet get configmap triage-report >/dev/null 2>&1; then
  echo "FAIL: ConfigMap triage-report does not exist in starfleet"
  exit 1
fi
fail=0
check() { # key, extended regex
  val="$(get "$1")"
  if ! printf '%s' "$val" | grep -Eqi "$2"; then
    echo "FAIL: key $1 is '${val}', expected a value that matches $2"
    fail=1
  fi
}
check ensign 'ImagePullBackOff|ErrImagePull'
check cadet 'CreateContainerConfigError'
check captain 'Unschedulable|FailedScheduling'
check engine 'OOMKilled'
check bridge 'app=bridge($|[^-a-z])'
if [ "$fail" -ne 0 ]; then exit 1; fi
echo "PASS: triage-report names all five causes"
