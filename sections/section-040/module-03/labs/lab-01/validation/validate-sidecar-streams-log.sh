#!/usr/bin/env bash
# Check: the log of the log-tail container contains ledger-event lines.
set -uo pipefail

for attempt in 1 2 3 4 5 6; do
  lines="$(kubectl -n starfleet logs deploy/ledger-writer -c log-tail --tail=20 2>/dev/null || true)"
  if printf '%s\n' "$lines" | grep -q 'ledger-event'; then
    echo "PASS: the log-tail container prints the ledger-event lines"
    exit 0
  fi
  sleep 5
done
echo "FAIL: the log of the log-tail container has no ledger-event lines; check the tail command and the volume mounts"
exit 1
