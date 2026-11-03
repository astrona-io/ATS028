#!/usr/bin/env bash
# Check: scout-findings key listen-port is the real listening port (9090).
set -uo pipefail

val="$(kubectl -n starfleet get configmap scout-findings -o jsonpath='{.data.listen-port}' 2>/dev/null | tr -d '[:space:]')"
if [ -z "$val" ]; then
  echo "FAIL: ConfigMap scout-findings in starfleet has no key listen-port"
  exit 1
fi
if [ "$val" != "9090" ]; then
  echo "FAIL: listen-port is '$val', but the process listens on a different port"
  exit 1
fi
echo "PASS: listen-port is 9090"
