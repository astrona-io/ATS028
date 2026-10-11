#!/usr/bin/env bash
set -euo pipefail
test "$(kubectl config current-context)" = "kind-astro-ats-028-playground-010-01"
practice_directory="$(mktemp -d)"
cleanup() {
  if [[ -n "${PORT_FORWARD_PID:-}" ]]; then kill "$PORT_FORWARD_PID" 2>/dev/null || true; fi
  rm -rf "$practice_directory"
}
trap cleanup EXIT
cd "$practice_directory"
wait_for_success() {
  for attempt in 1 2 3 4 5 6 7 8 9 10; do
    if "$@"; then return 0; fi
    sleep 1
  done
  return 1
}

kubectl api-resources --api-group=networking.k8s.io
kubectl explain ingress.spec.rules.http.paths --api-version=networking.k8s.io/v1
mkdir -p "$(dirname ingress-removed.yaml)"
cat > ingress-removed.yaml <<'CKAD_FILE_END'
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: probe
  namespace: starfleet
spec:
  backend:
    serviceName: probe
    servicePort: 80
CKAD_FILE_END
if kubectl apply --dry-run=server -f ingress-removed.yaml; then printf "Removed API unexpectedly accepted\n" >&2; exit 1; fi
mkdir -p "$(dirname ingress-current.yaml)"
cat > ingress-current.yaml <<'CKAD_FILE_END'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: probe
  namespace: starfleet
spec:
  ingressClassName: traefik
  rules:
  - host: probe.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: probe
            port:
              number: 80
CKAD_FILE_END
kubectl apply --dry-run=server -f ingress-current.yaml
kubectl apply --dry-run=server -f ingress-current.yaml >/dev/null
printf 'ATS028/010/01: live practice checks passed\n'
