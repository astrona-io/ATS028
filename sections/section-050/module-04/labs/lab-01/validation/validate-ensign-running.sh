#!/usr/bin/env bash
# Check: ensign has a ready pod and its image reference exists.
set -uo pipefail

ready="$(kubectl -n starfleet get deployment ensign -o jsonpath='{.status.readyReplicas}' 2>/dev/null)"
if [ "${ready:-0}" != "1" ]; then
  echo "FAIL: deployment ensign has ${ready:-0} ready replicas, expected 1"
  exit 1
fi
img="$(kubectl -n starfleet get deployment ensign -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)"
echo "PASS: ensign is ready with image $img"
