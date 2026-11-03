#!/usr/bin/env bash
# Check: beacon answers through its Service.
set -uo pipefail

if ! kubectl -n starfleet exec shuttle -- wget -q -T 3 -O- http://beacon/ready 2>/dev/null | grep -q 'version=v1'; then
  echo "FAIL: shuttle did not get a version=v1 answer from http://beacon/ready"
  exit 1
fi
echo "PASS: beacon answers through its Service"
