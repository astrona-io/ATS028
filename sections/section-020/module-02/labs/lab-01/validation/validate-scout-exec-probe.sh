#!/usr/bin/env bash
# Check: scout has an exec readiness probe, a command that runs, and a ready pod.
set -uo pipefail

spec="$(kubectl -n starfleet get deployment scout -o json 2>/dev/null)" || { echo "FAIL: scout not found"; exit 1; }
cmd="$(jq -r '.spec.template.spec.containers[0].readinessProbe.exec.command // empty | join(" ")' <<<"$spec")"
if [ -z "$cmd" ]; then
  echo "FAIL: scout needs readinessProbe.exec.command"
  exit 1
fi
ready="$(jq -r '.status.readyReplicas // 0' <<<"$spec")"
if [ "$ready" != "1" ]; then
  echo "FAIL: scout must have 1 ready replica (found: $ready)"
  exit 1
fi
echo "PASS: scout has an exec readiness probe ($cmd) and is ready"
