#!/usr/bin/env bash
# Check: beacon has an ephemeral container named inspector and is the original pod.
set -uo pipefail

names="$(kubectl -n starfleet get pod beacon -o jsonpath='{.spec.ephemeralContainers[*].name}' 2>/dev/null)"
case " $names " in
  *" inspector "*) ;;
  *) echo "FAIL: pod beacon has no ephemeral container named inspector"; exit 1 ;;
esac
want="$(kubectl -n default get configmap lab-baseline -o jsonpath='{.data.beacon-uid}' 2>/dev/null)"
have="$(kubectl -n starfleet get pod beacon -o jsonpath='{.metadata.uid}' 2>/dev/null)"
if [ -z "$want" ] || [ "$want" != "$have" ]; then
  echo "FAIL: pod beacon was deleted and created again"
  exit 1
fi
echo "PASS: inspector is attached to the original beacon pod"
