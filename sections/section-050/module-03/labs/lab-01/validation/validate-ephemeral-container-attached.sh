#!/usr/bin/env bash
# Check: scout has an ephemeral container named inspector that targets app.
set -uo pipefail

target="$(kubectl -n starfleet get pod scout -o jsonpath='{.spec.ephemeralContainers[?(@.name=="inspector")].targetContainerName}' 2>/dev/null)"
name="$(kubectl -n starfleet get pod scout -o jsonpath='{.spec.ephemeralContainers[*].name}' 2>/dev/null)"
case " $name " in
  *" inspector "*) ;;
  *) echo "FAIL: pod scout has no ephemeral container named inspector (found: ${name:-none})"; exit 1 ;;
esac
if [ "$target" != "app" ]; then
  echo "FAIL: inspector targets '${target:-nothing}', expected the container app"
  exit 1
fi
echo "PASS: ephemeral container inspector targets app"
