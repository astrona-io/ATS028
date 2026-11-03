#!/usr/bin/env bash
# Check: the pod template has a container named log-tail and the running pod has two ready containers.
set -uo pipefail

names="$(kubectl -n starfleet get deployment ledger-writer -o jsonpath='{.spec.template.spec.containers[*].name}' 2>/dev/null || true)"
case " $names " in
  *" log-tail "*) ;;
  *)
    echo "FAIL: the ledger-writer pod template has no container named log-tail (found: ${names:-nothing})"
    exit 1
    ;;
esac

if ! kubectl -n starfleet rollout status deployment/ledger-writer --timeout=90s >/dev/null 2>&1; then
  echo "FAIL: the rollout of ledger-writer has not finished; wait and submit again"
  exit 1
fi

ready="$(kubectl -n starfleet get pods -l app=ledger-writer -o jsonpath='{.items[0].status.containerStatuses[*].ready}' 2>/dev/null || true)"
if [ "$ready" != "true true" ]; then
  echo "FAIL: the ledger-writer pod must have two ready containers (ready flags: ${ready:-none})"
  exit 1
fi
echo "PASS: the ledger-writer pod runs two ready containers and one is named log-tail"
