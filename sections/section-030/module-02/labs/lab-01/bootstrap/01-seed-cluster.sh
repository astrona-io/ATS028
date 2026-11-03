#!/usr/bin/env bash
# Starting state for the selector lab. Environment only: it creates the
# workloads, the clients and a finished Job. It does not create the findings
# ConfigMap or the reviewed label the learner must add.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/starfleet.yaml"
for d in probe beacon scout; do
  kubectl -n starfleet rollout status "deployment/$d" --timeout=180s
done
kubectl -n starfleet wait --for=condition=Ready pod/shuttle --timeout=120s
kubectl -n starfleet wait --for=condition=Complete job/report-job --timeout=180s
echo "[lab] Ready."
