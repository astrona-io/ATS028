#!/usr/bin/env bash
# Reference solution, applied only by `astrona test`.
set -euo pipefail

NS=starfleet

kubectl -n $NS patch deployment hail --patch '{"spec":{"template":{"spec":{"containers":[{"name":"web","readinessProbe":{"httpGet":{"path":"/ready","port":"http"},"periodSeconds":3}}]}}}}'
kubectl -n $NS patch deployment dock --patch '{"spec":{"template":{"spec":{"containers":[{"name":"web","startupProbe":{"httpGet":{"path":"/health","port":"http"},"periodSeconds":5,"failureThreshold":24}}]}}}}'
kubectl -n $NS patch deployment keel --patch '{"spec":{"template":{"spec":{"containers":[{"name":"web","readinessProbe":{"tcpSocket":{"port":"http"},"periodSeconds":3},"livenessProbe":{"httpGet":{"path":"/health","port":"http"},"periodSeconds":10,"failureThreshold":3}}]}}}}'

kubectl -n $NS create configmap probe-report \
  --from-literal=hail-wrong-port=8081 \
  --from-literal=dock-startup-seconds=120 \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl -n $NS rollout status deployment/hail --timeout=240s
kubectl -n $NS rollout status deployment/dock --timeout=300s
kubectl -n $NS rollout status deployment/keel --timeout=240s
echo "[solution] Applied."
