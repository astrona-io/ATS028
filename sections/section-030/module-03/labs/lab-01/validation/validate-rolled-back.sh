#!/usr/bin/env bash
# Check: beacon runs the working image on 2 ready, updated replicas.
set -uo pipefail

img="$(kubectl -n starfleet get deployment beacon -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null || true)"
if [ "$img" != "docker.io/library/python:3.13-alpine" ]; then
  echo "FAIL: beacon image is '${img:-none}', expected docker.io/library/python:3.13-alpine"
  exit 1
fi
ready="$(kubectl -n starfleet get deployment beacon -o jsonpath='{.status.readyReplicas}' 2>/dev/null || true)"
updated="$(kubectl -n starfleet get deployment beacon -o jsonpath='{.status.updatedReplicas}' 2>/dev/null || true)"
if [ "$ready" != "2" ] || [ "$updated" != "2" ]; then
  echo "FAIL: beacon must have 2 ready and 2 updated replicas (ready: ${ready:-0}, updated: ${updated:-0})"
  exit 1
fi
echo "PASS: beacon is rolled back and ready"
