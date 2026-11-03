#!/usr/bin/env bash
# Reference solution, applied only by `astrona test`.
set -euo pipefail

NS=starfleet

# The causes are recorded first, as a learner would read them before fixing.
kubectl -n $NS create configmap triage-report \
  --from-literal=ensign=ImagePullBackOff \
  --from-literal=cadet=CreateContainerConfigError \
  --from-literal=captain=Unschedulable \
  --from-literal=engine=OOMKilled \
  --from-literal=bridge=app=bridge \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl -n $NS set image deployment/ensign main=docker.io/library/busybox:1.37.0
kubectl -n $NS create configmap cadet-settings --from-literal=mode=patrol \
  --dry-run=client -o yaml | kubectl apply -f -
kubectl -n $NS set resources deployment/captain --requests=cpu=100m
kubectl -n $NS set resources deployment/engine --limits=memory=256Mi
kubectl -n $NS patch service bridge --type=merge -p '{"spec":{"selector":{"app":"bridge"}}}'

for d in ensign cadet captain engine; do
  kubectl -n $NS rollout status "deployment/$d" --timeout=180s
done
