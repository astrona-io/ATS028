#!/usr/bin/env bash
# Reference solution, applied only by `astrona test`.
set -euo pipefail

NS=starfleet
current_bad="$(kubectl -n $NS get deployment beacon -o jsonpath='{.spec.template.spec.containers[0].image}')"
reason=""
for _ in $(seq 1 30); do
  reason="$(kubectl -n $NS get pods -l app=beacon -o jsonpath='{range .items[*]}{.status.containerStatuses[0].state.waiting.reason}{"\n"}{end}' | grep -E 'ErrImagePull|ImagePullBackOff' | head -n1 || true)"
  [ -n "$reason" ] && break
  sleep 3
done

kubectl -n $NS create configmap rollout-report \
  --from-literal=failed-image="$current_bad" \
  --from-literal=reason="${reason:-ImagePullBackOff}" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl -n $NS rollout undo deployment/beacon
kubectl -n $NS rollout status deployment/beacon --timeout=180s
kubectl -n $NS annotate deployment/beacon kubernetes.io/change-cause="rollback: image tag python:3.13-alpine-missing does not exist" --overwrite
