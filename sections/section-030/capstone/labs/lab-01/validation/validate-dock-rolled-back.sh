#!/usr/bin/env bash
# Check: dock runs the working image on 2 ready, updated replicas and keeps its history.
set -uo pipefail

img="$(kubectl -n starfleet get deployment dock -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null || true)"
if [ "$img" != "docker.io/library/python:3.13-alpine" ]; then
  echo "FAIL: dock image is '${img:-none}', expected docker.io/library/python:3.13-alpine"
  exit 1
fi
ready="$(kubectl -n starfleet get deployment dock -o jsonpath='{.status.readyReplicas}' 2>/dev/null || true)"
updated="$(kubectl -n starfleet get deployment dock -o jsonpath='{.status.updatedReplicas}' 2>/dev/null || true)"
if [ "$ready" != "2" ] || [ "$updated" != "2" ]; then
  echo "FAIL: dock must have 2 ready and 2 updated replicas (ready: ${ready:-0}, updated: ${updated:-0})"
  exit 1
fi
sets="$(kubectl -n starfleet get replicasets -l app=dock -o name 2>/dev/null | wc -l | tr -d ' ')"
if [ "$sets" -lt 2 ]; then
  echo "FAIL: the failed ReplicaSet of dock was deleted; keep the revision history"
  exit 1
fi
cause="$(kubectl -n starfleet get deployment dock -o jsonpath='{.metadata.annotations.kubernetes\.io/change-cause}' 2>/dev/null || true)"
if [ -z "$cause" ] || [ "$cause" = "update to a new tag" ] || [ "$cause" = "initial release" ]; then
  echo "FAIL: set kubernetes.io/change-cause on dock to a new text that describes the rollback (found: ${cause:-nothing})"
  exit 1
fi
echo "PASS: dock is rolled back and its change-cause is '$cause'"
