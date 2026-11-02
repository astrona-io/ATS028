#!/usr/bin/env bash
set -euo pipefail
test "$(kubectl config current-context)" = "kind-astro-ats-028-playground-030-01"
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

kubectl -n starfleet get deployments,pods -o wide
kubectl -n starfleet describe deployment probe
kubectl -n starfleet get events --sort-by=.metadata.creationTimestamp
kubectl wait --for=condition=Available apiservice/v1beta1.metrics.k8s.io --timeout=120s
wait_for_success kubectl -n starfleet top pods
wait_for_success kubectl top nodes
kubectl -n starfleet get deployment probe -o jsonpath='{.spec.template.spec.containers[0].resources}{"\n"}'
kubectl -n starfleet logs deployment/probe --tail=10
kubectl get --raw /apis/metrics.k8s.io/v1beta1/namespaces/starfleet/pods >/dev/null
printf 'ATS028/030/01: live practice checks passed\n'
