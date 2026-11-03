#!/usr/bin/env bash
# Reference solution, applied only by `astrona test`.
set -euo pipefail

NS=starfleet
code="$(kubectl -n $NS logs deploy/manifest -c audit --tail=60 | grep -o 'code=E[0-9]*' | head -1 | cut -d= -f2)"
key="$( { kubectl -n $NS logs -l app=valve -c app --previous 2>/dev/null || kubectl -n $NS logs -l app=valve -c app; } | grep -o 'VALVE_KEY_[0-9]*' | head -1)"
pods="$(kubectl -n $NS get pods -l app=manifest -o name | wc -l | tr -d ' ')"
containers="$(kubectl -n $NS get deployment manifest -o jsonpath='{range .spec.template.spec.containers[*]}{.name}{"\n"}{end}' | sort | paste -sd, -)"

kubectl -n $NS create configmap log-report \
  --from-literal=audit-code="$code" \
  --from-literal=valve-key="$key" \
  --from-literal=pods="$pods" \
  --from-literal=containers="$containers" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl -n $NS apply -f - <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gauge
  namespace: starfleet
spec:
  replicas: 1
  selector:
    matchLabels:
      app: gauge
  template:
    metadata:
      labels:
        app: gauge
    spec:
      volumes:
        - name: gauge-logs
          emptyDir: {}
      containers:
        - name: writer
          image: docker.io/library/busybox:1.37.0
          command:
            - sh
            - -c
            - 'mkdir -p /var/log/gauge; while true; do echo "$(date +%T) gauge-reading value=$RANDOM" >> /var/log/gauge/gauge.log; sleep 2; done'
          volumeMounts:
            - name: gauge-logs
              mountPath: /var/log/gauge
        - name: log-tail
          image: docker.io/library/busybox:1.37.0
          command: ["sh", "-c", "tail -n+1 -F /var/log/gauge/gauge.log"]
          volumeMounts:
            - name: gauge-logs
              mountPath: /var/log/gauge
              readOnly: true
YAML
kubectl -n $NS rollout status deployment/gauge --timeout=180s
