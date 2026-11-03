#!/usr/bin/env bash
# Reference solution. Run only by `astrona test`.
set -euo pipefail

kubectl -n starfleet patch deployment beacon --type=json -p '[
  {"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/path","value":"/ready"},
  {"op":"replace","path":"/spec/template/spec/containers/0/livenessProbe/tcpSocket/port","value":"http"}
]'
kubectl -n starfleet rollout status deployment/beacon --timeout=180s

kubectl -n starfleet patch deployment scout --patch '{"spec":{"template":{"spec":{"containers":[{"name":"web","readinessProbe":{"exec":{"command":["sh","-c","wget -q -T 2 -O /dev/null http://127.0.0.1:8080/ready"]},"periodSeconds":3,"timeoutSeconds":3}}]}}}}'
kubectl -n starfleet rollout status deployment/scout --timeout=180s
echo "[solution] Applied."
