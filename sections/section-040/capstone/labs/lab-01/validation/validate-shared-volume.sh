#!/usr/bin/env bash
# Check: writer and log-tail mount the same emptyDir volume at /var/log/gauge, and log-tail mounts it read-only.
set -uo pipefail

path='{.spec.template.spec.containers[?(@.name=="%s")].volumeMounts[?(@.mountPath=="/var/log/gauge")].%s}'
get() { kubectl -n starfleet get deployment gauge -o jsonpath="$(printf "$path" "$1" "$2")" 2>/dev/null || true; }

writer_volume="$(get writer name)"
tail_volume="$(get log-tail name)"
tail_readonly="$(get log-tail readOnly)"

if [ -z "$writer_volume" ]; then
  echo "FAIL: the writer container must mount a volume at /var/log/gauge"
  exit 1
fi
if [ "$tail_volume" != "$writer_volume" ]; then
  echo "FAIL: log-tail must mount the same volume as writer at /var/log/gauge (writer: $writer_volume, log-tail: ${tail_volume:-nothing})"
  exit 1
fi
if [ "$tail_readonly" != "true" ]; then
  echo "FAIL: log-tail must mount the volume with readOnly: true"
  exit 1
fi
volume="$(kubectl -n starfleet get deployment gauge -o jsonpath="{.spec.template.spec.volumes[?(@.name==\"$writer_volume\")]}" 2>/dev/null || true)"
case "$volume" in
  *emptyDir*) ;;
  *)
    echo "FAIL: the volume $writer_volume must be an emptyDir volume"
    exit 1
    ;;
esac
echo "PASS: both containers mount the emptyDir volume $writer_volume and log-tail mounts it read-only"
