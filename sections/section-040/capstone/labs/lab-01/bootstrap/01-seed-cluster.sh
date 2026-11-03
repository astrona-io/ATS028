#!/usr/bin/env bash
# Starting state: manifest (two containers, three pods), valve (crash loop) and
# gauge (writes only to a file). The error code and the variable name are random.
# The report ConfigMap and the sidecar are not created.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

CODE="E$(( (RANDOM % 900) + 100 ))"
KEY="VALVE_KEY_$(( (RANDOM % 900) + 100 ))"

kubectl apply -f "$DIR/manifests/starfleet.yaml"
sed -e "s/__CODE__/$CODE/" -e "s/__KEY__/$KEY/" "$DIR/manifests/workloads.yaml" | kubectl apply -f -
kubectl -n starfleet rollout status deployment/manifest --timeout=180s
kubectl -n starfleet rollout status deployment/gauge --timeout=180s
kubectl -n starfleet wait --for=jsonpath='{.status.containerStatuses[0].restartCount}'=1 pod -l app=valve --timeout=120s || true
echo "[lab] Ready."
