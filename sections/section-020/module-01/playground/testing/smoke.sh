#!/usr/bin/env bash
set -euo pipefail
test "$(kubectl config current-context)" = "kind-astro-ats-028-playground-020-01"
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

kubectl -n starfleet patch deployment probe --type=strategic -p '{"spec":{"template":{"spec":{"containers":[{"name":"probe","livenessProbe":{"httpGet":{"path":"/health","port":"http"},"periodSeconds":2,"failureThreshold":3}}]}}}}'
kubectl -n starfleet scale deployment/probe --replicas=1
kubectl -n starfleet rollout status deployment/probe --timeout=120s
PROBE_POD=$(kubectl -n starfleet get pods -l app=probe -o jsonpath='{.items[0].metadata.name}')
kubectl -n starfleet exec "$PROBE_POD" -- touch /tmp/not-ready
kubectl -n starfleet wait --for=condition=Ready=false pod/"$PROBE_POD" --timeout=30s
kubectl -n starfleet get endpointslice -l kubernetes.io/service-name=probe -o yaml
kubectl -n starfleet exec "$PROBE_POD" -- rm /tmp/not-ready
kubectl -n starfleet wait --for=condition=Ready pod/"$PROBE_POD" --timeout=30s
kubectl -n starfleet exec "$PROBE_POD" -- touch /tmp/unhealthy
kubectl -n starfleet wait --for=jsonpath='{.status.containerStatuses[0].restartCount}'=1 pod/"$PROBE_POD" --timeout=60s
kubectl -n starfleet wait --for=condition=Ready pod/"$PROBE_POD" --timeout=60s
kubectl -n starfleet describe pod "$PROBE_POD"
test "$(kubectl -n starfleet get pod "$PROBE_POD" -o jsonpath='{.status.containerStatuses[0].restartCount}')" -ge 1
printf 'ATS028/020/01: live practice checks passed\n'
