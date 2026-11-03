#!/usr/bin/env bash
# Check: fuse-key equals the variable named in the fuse pod log.
set -uo pipefail

logs="$(kubectl -n starfleet logs -l app=fuse -c app --previous 2>/dev/null || kubectl -n starfleet logs -l app=fuse -c app 2>/dev/null || true)"
expected="$(printf '%s\n' "$logs" | grep -o 'FUSE_KEY_[0-9]*' | head -1)"
found="$(kubectl -n starfleet get configmap log-findings -o jsonpath='{.data.fuse-key}' 2>/dev/null || true)"

if [ -z "$expected" ]; then
  echo "FAIL: the fuse pod has no log yet; wait a few seconds and submit again"
  exit 1
fi
if [ "$found" != "$expected" ]; then
  echo "FAIL: log-findings key fuse-key must be the variable named in the fuse log (found: ${found:-nothing})"
  exit 1
fi
echo "PASS: fuse-key matches the fuse log"
