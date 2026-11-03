#!/usr/bin/env bash
# Reference solution. Run only by `astrona test`.
set -euo pipefail

kubectl -n starfleet patch deployment beacon --patch '{"spec":{"template":{"spec":{"containers":[{"name":"web","startupProbe":{"httpGet":{"path":"/health","port":"http"},"periodSeconds":5,"failureThreshold":24}}]}}}}'
kubectl -n starfleet rollout status deployment/beacon --timeout=240s
kubectl -n starfleet create configmap probe-budget --from-literal=startup-seconds=120
echo "[solution] Applied."
