#!/usr/bin/env bash
# Check: the beacon Deployment has a change-cause that is not the seeded one.
set -uo pipefail

cause="$(kubectl -n starfleet get deployment beacon -o jsonpath='{.metadata.annotations.kubernetes\.io/change-cause}' 2>/dev/null || true)"
if [ -z "$cause" ]; then
  echo "FAIL: beacon has no kubernetes.io/change-cause annotation"
  exit 1
fi
if [ "$cause" = "update to a new tag" ] || [ "$cause" = "initial release" ]; then
  echo "FAIL: change-cause still holds the seeded text '$cause'; describe the rollback"
  exit 1
fi
echo "PASS: change-cause is '$cause'"
