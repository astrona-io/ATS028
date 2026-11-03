# Solution: Fix And Add Probe Handlers

## 1. Read the evidence

```sh
kubectl -n starfleet get pods -l app=beacon
kubectl -n starfleet describe pod -l app=beacon | grep -A2 Unhealthy
```

The readiness events say `HTTP probe failed with statuscode: 404`, so the path `/readyz` does not exist. The liveness events say `connect: connection refused`, so nothing listens on port 9090.

Check the application directly:

```sh
kubectl -n starfleet exec shuttle -- wget -S -q -O- -T 3 http://beacon/ready
```

## 2. Fix beacon

```sh
kubectl -n starfleet patch deployment beacon --type=json -p '[
  {"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/path","value":"/ready"},
  {"op":"replace","path":"/spec/template/spec/containers/0/livenessProbe/tcpSocket/port","value":"http"}
]'
kubectl -n starfleet rollout status deployment/beacon --timeout=180s
```

The patch changes the pod template, so the Deployment creates new pods with the fixed probes. The old pods are removed after the new ones are ready.

## 3. Add the exec probe to scout

```sh
kubectl -n starfleet patch deployment scout --patch '{"spec":{"template":{"spec":{"containers":[{"name":"web","readinessProbe":{"exec":{"command":["sh","-c","wget -q -T 2 -O /dev/null http://127.0.0.1:8080/ready"]},"periodSeconds":3,"timeoutSeconds":3}}]}}}}'
kubectl -n starfleet rollout status deployment/scout --timeout=180s
```

The command is a list. The `sh -c` form is required because the single argument contains a full command line.

## 4. Verify

```sh
kubectl -n starfleet get deployment beacon scout
kubectl -n starfleet get pods -l app=beacon
astrona submit
```

Both Deployments show all replicas ready, and the `RESTARTS` column for beacon is 0.
