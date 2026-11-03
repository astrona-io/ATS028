#!/usr/bin/env bash
# Starting state: the outpost namespace with the relay Service (no pods yet), a
# client pod and a ConfigMap that holds four legacy manifests. The Deployment,
# CronJob, PodDisruptionBudget, HorizontalPodAutoscaler and the findings
# ConfigMap are not created.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/outpost.yaml"
kubectl -n outpost wait --for=condition=Ready pod/drifter --timeout=120s
echo "[lab] Ready."
