#!/usr/bin/env bash
# Reference solution, applied only by `astrona test`.
set -euo pipefail

NS=starfleet
port="$(kubectl -n $NS exec beacon -- netstat -tln | awk '$6 == "LISTEN" {n=split($4, a, ":"); print a[n]; exit}')"
build="$(kubectl -n $NS exec beacon -- printenv BUILD_ID)"

kubectl -n $NS create configmap capstone-report \
  --from-literal=hail=Unhealthy \
  --from-literal=dock=ImagePullBackOff \
  --from-literal=beacon-build="$build" \
  --from-literal=beacon-port="$port" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl -n $NS debug beacon -c inspector \
  --image=docker.io/library/busybox:1.37.0 --target=app -- sleep 3600

kubectl -n $NS patch deployment hail --type=json \
  -p '[{"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/port","value":"http"}]'
kubectl -n $NS set image deployment/dock main=docker.io/library/busybox:1.37.0
for d in hail dock; do
  kubectl -n $NS rollout status "deployment/$d" --timeout=180s
done
