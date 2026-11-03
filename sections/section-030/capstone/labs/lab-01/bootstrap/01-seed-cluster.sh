#!/usr/bin/env bash
# Starting state: hail (web, prod), keel (data, prod), a crash-looping pod valve-<number>,
# and dock (web, stage), whose update to a missing image tag is stuck.
# The report ConfigMap, the labels and the rollback are not created.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SUFFIX="$(( (RANDOM % 900) + 100 ))"

sed -e "s/__SUFFIX__/$SUFFIX/" "$DIR/manifests/starfleet.yaml" | kubectl apply -f -
for d in hail dock keel; do
  kubectl -n starfleet rollout status "deployment/$d" --timeout=180s
done
kubectl -n starfleet wait --for=condition=Ready pod/shuttle --timeout=120s

kubectl -n starfleet annotate deployment/dock kubernetes.io/change-cause="initial release" --overwrite
kubectl -n starfleet set image deployment/dock main=docker.io/library/python:3.13-alpine3.99
kubectl -n starfleet annotate deployment/dock kubernetes.io/change-cause="update to a new tag" --overwrite
# Give valve time to run and restart at least once.
kubectl -n starfleet wait --for=jsonpath='{.status.containerStatuses[0].restartCount}'=1 pod -l app=valve --timeout=120s || true
echo "[lab] Ready. The dock rollout is stuck and valve restarts on purpose."
