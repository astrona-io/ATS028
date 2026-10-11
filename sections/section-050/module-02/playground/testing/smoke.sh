#!/usr/bin/env bash
set -euo pipefail
test "$(kubectl config current-context)" = "kind-astro-ats-028-playground-050-02"
practice_directory="$(mktemp -d)"
cleanup() {
  if [[ -n "${PORT_FORWARD_PID:-}" ]]; then kill "$PORT_FORWARD_PID" 2>/dev/null || true; fi
  rm -rf "$practice_directory"
}
trap cleanup EXIT
cd "$practice_directory"
wait_for_success() {
  for attempt in 1 2 3 4 5 6 7 8 9 10; do
    if "$@"; then return 0; fi
    sleep 1
  done
  return 1
}

mkdir -p "$(dirname deployment-probe-settings.yaml)"
cat > deployment-probe-settings.yaml <<'CKAD_FILE_END'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: probe
  namespace: starfleet
spec:
  replicas: 2
  selector:
    matchLabels:
      app: probe
      release: probe
  template:
    metadata:
      labels:
        app: probe
        release: probe
    spec:
      containers:
      - name: probe
        image: docker.io/library/python:3.13-alpine
        command:
        - python
        - /app/server.py
        env:
        - name: VERSION
          value: v1
        - name: GREETING
          valueFrom:
            configMapKeyRef:
              name: runtime-settings
              key: greeting
        ports:
        - name: http
          containerPort: 8080
        readinessProbe:
          httpGet:
            path: /ready
            port: http
          periodSeconds: 2
        resources:
          requests:
            cpu: 10m
            memory: 32Mi
          limits:
            memory: 128Mi
        volumeMounts:
        - name: app
          mountPath: /app
          readOnly: true
      volumes:
      - name: app
        configMap:
          name: probe-code
CKAD_FILE_END
kubectl apply -f deployment-probe-settings.yaml
kubectl -n starfleet get pods -l app=probe
kubectl -n starfleet describe pods -l app=probe
kubectl -n starfleet get configmap runtime-settings --ignore-not-found
kubectl -n starfleet create configmap runtime-settings --from-literal=greeting=repaired
kubectl -n starfleet rollout status deployment/probe --timeout=120s
wait_for_success kubectl -n starfleet exec shuttle -- wget -qO- http://probe/
kubectl -n starfleet get endpointslice -l kubernetes.io/service-name=probe -o yaml
kubectl -n starfleet logs deployment/probe --tail=10
kubectl -n starfleet exec shuttle -- wget -qO- http://probe/ | grep -q 'greeting=repaired'
printf 'ATS028/050/02: live practice checks passed\n'
