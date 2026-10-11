---
draft: true
exam_objectives:
- Debugging in Kubernetes
---
# Repair A Missing Configuration Dependency

The new Pod template asks for an environment value from a ConfigMap that does not yet exist. You will observe the preparation failure, create the exact missing dependency and check the recovered request path. A Service connection failure can be a consequence rather than the first cause.

Use the module playground and its private kubeconfig. The context check below prevents commands from being directed at an unrelated cluster. The helper retries a command for a bounded interval after controller or policy changes; it cannot turn a persistent failure into success. Read the actual errors when the interval expires.

<!-- astrona:playground:renew -->

For a timed catalog session, renew this module before continuing. Skip renewal for an untimed local author run:

```sh
astrona run renew astrona-io/ATS028/section-050/module-02/playground
```

Select the module environment and define a bounded retry helper:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-028-playground-050-02)"
test "$(kubectl config current-context)" = "kind-astro-ats-028-playground-050-02"
kubectl -n starfleet get pods
wait_for_success() {
  for attempt in 1 2 3 4 5 6 7 8 9 10; do
    if "$@"; then return 0; fi
    sleep 1
  done
  return 1
}
```

Save the complete Deployment with its configuration reference and apply it.

Save this as `deployment-probe-settings.yaml`:

```yaml
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
```

Apply or use the saved input, then check the result:

```sh
kubectl apply -f deployment-probe-settings.yaml
kubectl -n starfleet get pods -l app=probe
kubectl -n starfleet describe pods -l app=probe
```

The API can accept a reference before the dependency exists. Inspect container preparation state and events instead of assuming that the application started and rejected requests.

Confirm the referenced ConfigMap is absent, then create that name and key.

```sh
kubectl -n starfleet get configmap runtime-settings --ignore-not-found
kubectl -n starfleet create configmap runtime-settings --from-literal=greeting=repaired
kubectl -n starfleet rollout status deployment/probe --timeout=120s
```

The reference requires a particular key, not just any ConfigMap. Repairing the named dependency is more focused than changing the Service, image and probe at the same time.

Read the recovered application response and Service endpoint evidence.

```sh
wait_for_success kubectl -n starfleet exec shuttle -- wget -qO- http://probe/
kubectl -n starfleet get endpointslice -l kubernetes.io/service-name=probe -o yaml
kubectl -n starfleet logs deployment/probe --tail=10
```

The greeting should identify the repaired configuration. This verifies the selected path after correction; it does not prove that every external application dependency is healthy.

Diagnosis follows the resource reference through preparation, readiness and Service eligibility. Environment values are captured at container start, so a later ConfigMap edit has a different update contract from repairing an absent initial dependency. Keep the authoritative template and observed outcome together.

## Common pitfalls

> [!WARNING]
> Keep the selected module context and inspect the observed outcome. Resource acceptance does not establish readiness or a successful request. Reset this isolated environment if earlier experiments changed the required starting state.
