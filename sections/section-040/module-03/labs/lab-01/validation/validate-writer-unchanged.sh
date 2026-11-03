#!/usr/bin/env bash
# Check: the writer container keeps its image and its file path, and the Deployment keeps 1 replica.
set -uo pipefail

fail=0
base='{.spec.template.spec.containers[?(@.name=="writer")]'
image="$(kubectl -n starfleet get deployment ledger-writer -o jsonpath="$base.image}" 2>/dev/null || true)"
command="$(kubectl -n starfleet get deployment ledger-writer -o jsonpath="$base.command}" 2>/dev/null || true)"
replicas="$(kubectl -n starfleet get deployment ledger-writer -o jsonpath='{.spec.replicas}' 2>/dev/null || true)"

if [ "$image" != "docker.io/library/busybox:1.37.0" ]; then
  echo "FAIL: the writer container must keep the image docker.io/library/busybox:1.37.0 (found: ${image:-no writer container})"
  fail=1
fi
case "$command" in
  *"/var/log/app/app.log"*"ledger-event"*|*"ledger-event"*"/var/log/app/app.log"*) ;;
  *)
    echo "FAIL: the writer container must keep its command that appends ledger-event lines to /var/log/app/app.log"
    fail=1
    ;;
esac
if [ "$replicas" != "1" ]; then
  echo "FAIL: the ledger-writer Deployment must keep 1 replica (found: ${replicas:-none})"
  fail=1
fi
[ "$fail" -eq 0 ] && echo "PASS: the writer container and the replica count are unchanged"
exit "$fail"
