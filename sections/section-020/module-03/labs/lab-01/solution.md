# Solution: Size A Startup Probe

## 1. Read the evidence

```sh
kubectl -n starfleet get pods -l app=beacon
kubectl -n starfleet describe pod -l app=beacon | grep -E 'Unhealthy|Killing'
```

The events show `Liveness probe failed: ... connection refused` and `will be restarted`. The liveness probe has `initialDelaySeconds: 5`, `periodSeconds: 5` and `failureThreshold: 2`, so it kills the container after about 15 seconds. The application needs 45.

## 2. Add the startup probe

```sh
kubectl -n starfleet patch deployment beacon --patch '{"spec":{"template":{"spec":{"containers":[{"name":"web","startupProbe":{"httpGet":{"path":"/health","port":"http"},"periodSeconds":5,"failureThreshold":24}}]}}}}'
kubectl -n starfleet rollout status deployment/beacon --timeout=240s
```

The budget is 24 times 5 seconds, which is 120 seconds. Liveness and readiness stay disabled until the startup probe succeeds, so the liveness probe can stay fast.

## 3. Record the budget

```sh
kubectl -n starfleet create configmap probe-budget --from-literal=startup-seconds=120
```

## 4. Verify

```sh
kubectl -n starfleet get pods -l app=beacon
astrona submit
```

Both pods show `1/1` and `RESTARTS` is 0.
