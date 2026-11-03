#!/usr/bin/env bash
# Reference solution, applied only by `astrona test`.
set -euo pipefail

NS=starfleet

pods="$(kubectl -n $NS get pods -l tier=web,env=prod -o name | sed 's#^pod/##' | sort)"
valve="$(kubectl -n $NS get pods -l app=valve -o jsonpath='{.items[0].metadata.name}')"
failed="$(kubectl -n $NS get deployment dock -o jsonpath='{.spec.template.spec.containers[0].image}')"
reason="$(kubectl -n $NS get pods -l app=dock -o jsonpath='{range .items[*]}{.status.containerStatuses[0].state.waiting.reason}{"\n"}{end}' | grep -E 'ErrImagePull|ImagePullBackOff' | head -1)"

kubectl -n $NS create configmap fleet-report \
  --from-literal=prod-web-pods="$pods" \
  --from-literal=restarting-pod="$valve" \
  --from-literal=failed-image="$failed" \
  --from-literal=reason="$reason" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl -n $NS label pods -l env=prod reviewed=true --overwrite
kubectl -n $NS rollout undo deployment/dock
kubectl -n $NS annotate deployment/dock kubernetes.io/change-cause="rolled back the missing image tag" --overwrite
kubectl -n $NS rollout status deployment/dock --timeout=180s
echo "[solution] Applied."
