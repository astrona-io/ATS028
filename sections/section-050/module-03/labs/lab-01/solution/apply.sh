#!/usr/bin/env bash
# Reference solution, applied only by `astrona test`.
set -euo pipefail

NS=starfleet
port="$(kubectl -n $NS exec scout -- netstat -tln | awk '$6 == "LISTEN" {n=split($4, a, ":"); print a[n]; exit}')"
version="$(kubectl -n $NS exec scout -- printenv APP_VERSION)"

kubectl -n $NS create configmap scout-findings \
  --from-literal=listen-port="$port" \
  --from-literal=app-version="$version" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl -n $NS debug scout -c inspector \
  --image=docker.io/library/busybox:1.37.0 --target=app -- sleep 3600

kubectl -n $NS patch service scout --type=merge \
  -p "{\"spec\":{\"ports\":[{\"name\":\"http\",\"port\":80,\"targetPort\":$port}]}}"
