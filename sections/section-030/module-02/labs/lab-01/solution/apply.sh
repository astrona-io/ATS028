#!/usr/bin/env bash
# Reference solution, applied only by `astrona test`.
set -euo pipefail

NS=starfleet
web="$(kubectl -n $NS get pods -l tier=web,env=prod -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | sort)"
images="$(kubectl -n $NS get pods -o jsonpath='{range .items[*]}{range .spec.containers[*]}{.image}{"\n"}{end}{end}' | sort -u)"
done_pod="$(kubectl -n $NS get pods --field-selector=status.phase=Succeeded -o jsonpath='{.items[0].metadata.name}')"

kubectl -n $NS create configmap findings \
  --from-literal=web-pods="$web" \
  --from-literal=images="$images" \
  --from-literal=completed-pod="$done_pod" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl -n $NS label pods -l tier=web,env=prod reviewed=true --overwrite
