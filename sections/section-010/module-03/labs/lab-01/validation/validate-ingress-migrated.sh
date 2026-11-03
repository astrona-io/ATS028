#!/usr/bin/env bash
# Check: Ingress probe-edge is stored in networking.k8s.io/v1 with the class
# field, an explicit path type and a service backend.
set -uo pipefail

NS=starfleet
get() {
  kubectl -n "$NS" get ingresses.v1.networking.k8s.io probe-edge -o jsonpath="$1" 2>/dev/null || true
}

if ! kubectl -n "$NS" get ingresses.v1.networking.k8s.io probe-edge >/dev/null 2>&1; then
  echo "FAIL: Ingress probe-edge not found in networking.k8s.io/v1"
  exit 1
fi

fail=0
[ "$(get '{.spec.ingressClassName}')" = "nginx" ] || { echo "FAIL: spec.ingressClassName must be nginx"; fail=1; }
[ -z "$(get '{.metadata.annotations.kubernetes\.io/ingress\.class}')" ] || { echo "FAIL: remove the kubernetes.io/ingress.class annotation"; fail=1; }
[ "$(get '{.spec.rules[0].host}')" = "edge.starfleet.example" ] || { echo "FAIL: host must stay edge.starfleet.example"; fail=1; }
[ "$(get '{.spec.rules[0].http.paths[0].path}')" = "/status" ] || { echo "FAIL: path must stay /status"; fail=1; }
[ -n "$(get '{.spec.rules[0].http.paths[0].pathType}')" ] || { echo "FAIL: pathType is missing"; fail=1; }
[ "$(get '{.spec.rules[0].http.paths[0].backend.service.name}')" = "probe" ] || { echo "FAIL: backend.service.name must be probe"; fail=1; }
[ "$(get '{.spec.rules[0].http.paths[0].backend.service.port.number}')" = "80" ] || { echo "FAIL: backend.service.port.number must be 80"; fail=1; }

[ "$fail" -eq 0 ] && echo "PASS: Ingress probe-edge uses the networking.k8s.io/v1 fields"
exit "$fail"
