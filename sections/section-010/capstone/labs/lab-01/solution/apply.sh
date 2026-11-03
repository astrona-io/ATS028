#!/usr/bin/env bash
# Reference solution, applied only by `astrona test`.
set -euo pipefail

kubectl apply -f - <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: relay
  namespace: outpost
spec:
  replicas: 2
  selector:
    matchLabels:
      app: relay
  template:
    metadata:
      labels:
        app: relay
    spec:
      containers:
        - name: relay
          image: docker.io/library/python:3.13-alpine
          command:
            - python
            - /app/server.py
          ports:
            - name: http
              containerPort: 8080
          readinessProbe:
            httpGet:
              path: /ready
              port: http
            periodSeconds: 2
          volumeMounts:
            - name: app
              mountPath: /app
              readOnly: true
      volumes:
        - name: app
          configMap:
            name: probe-code
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: beacon-sweep
  namespace: outpost
spec:
  schedule: "*/15 * * * *"
  concurrencyPolicy: Replace
  failedJobsHistoryLimit: 3
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          containers:
            - name: sweep
              image: docker.io/library/busybox:1.37.0
              command: ["sh", "-c", "wget -q -T 3 -O- http://relay/"]
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: relay-budget
  namespace: outpost
spec:
  maxUnavailable: 1
  selector:
    matchLabels:
      app: relay
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: relay-scaler
  namespace: outpost
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: relay
  minReplicas: 2
  maxReplicas: 6
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 60
YAML

kubectl -n outpost create configmap api-audit \
  --from-literal=deployment=apps/v1 \
  --from-literal=cronjob=batch/v1 \
  --from-literal=pdb=policy/v1 \
  --from-literal=hpa=autoscaling/v2 \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl -n outpost rollout status deployment/relay --timeout=180s
echo "[solution] Applied."
