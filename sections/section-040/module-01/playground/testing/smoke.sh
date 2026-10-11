#!/usr/bin/env bash
set -euo pipefail
test "$(kubectl config current-context)" = "kind-astro-ats-028-playground-040-01"
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

mkdir -p "$(dirname pod-crash-report.yaml)"
cat > pod-crash-report.yaml <<'CKAD_FILE_END'
apiVersion: v1
kind: Pod
metadata:
  name: crash-report
  namespace: starfleet
spec:
  containers:
  - name: report
    image: docker.io/library/busybox:1.37.0
    command:
    - sh
    - -c
    - printf "application-started\n"; sleep 2; exit 12
CKAD_FILE_END
kubectl apply -f pod-crash-report.yaml
kubectl -n starfleet wait --for=jsonpath='{.status.containerStatuses[0].restartCount}'=1 pod/crash-report --timeout=60s
kubectl -n starfleet logs crash-report -c report --previous --timestamps
kubectl -n starfleet describe pod crash-report
kubectl -n starfleet get pod crash-report -o yaml
wait_for_success kubectl -n starfleet exec shuttle -- wget -qO- http://probe/
kubectl -n starfleet logs deployment/probe --tail=10 --timestamps
kubectl -n starfleet delete pod crash-report
test -z "$(kubectl -n starfleet get pod crash-report --ignore-not-found -o name)"
printf 'ATS028/040/01: live practice checks passed\n'
