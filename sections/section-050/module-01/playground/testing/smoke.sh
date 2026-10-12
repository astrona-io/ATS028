#!/usr/bin/env bash
set -euo pipefail
test "$(kubectl config current-context)" = "kind-astro-ats-028-playground-050-01"
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

kubectl -n starfleet patch deployment probe -p '{"spec":{"template":{"spec":{"nodeSelector":{"training.example/eligible":"missing"}}}}}'
kubectl get nodes --show-labels
kubectl -n starfleet get pods -l app=probe -o wide
kubectl -n starfleet describe pods -l app=probe
kubectl -n starfleet get events --sort-by=.metadata.creationTimestamp
kubectl -n starfleet get replicasets -l app=probe
kubectl -n starfleet patch deployment probe --type=json -p '[{"op":"remove","path":"/spec/template/spec/nodeSelector"}]'
kubectl -n starfleet rollout status deployment/probe --timeout=120s
wait_for_success kubectl -n starfleet exec shuttle -- wget -qO- http://probe/
test "$(kubectl -n starfleet get deploy probe -o jsonpath='{.status.availableReplicas}')" = 2
printf 'ATS028/050/01: live practice checks passed\n'
