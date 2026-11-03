#!/usr/bin/env bash
# Check: scout keeps its labels and Service, and answers requests.
set -uo pipefail

if ! kubectl -n starfleet exec shuttle -- wget -q -T 3 -O- http://scout/ready 2>/dev/null | grep -q 'version=v1'; then
  echo "FAIL: shuttle did not get a version=v1 answer from http://scout/ready"
  exit 1
fi
echo "PASS: scout answers through its Service"
