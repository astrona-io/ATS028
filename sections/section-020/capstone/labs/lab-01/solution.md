# Solution: Repair And Add Probes On Three Workloads

## Step 1. Find the cause for hail

```sh
kubectl -n starfleet get pods -l app=hail
kubectl -n starfleet describe pod -l app=hail
```

The pods show `Running` with `0/1` ready. In the events, the line with `Unhealthy` says that the readiness probe failed on a URL with port 8081 and that the connection was refused. The application listens on 8080, so nothing answers on 8081. Note the port 8081.

## Step 2. Fix the readiness probe of hail

```sh
kubectl -n starfleet patch deployment hail --patch '{"spec":{"template":{"spec":{"containers":[{"name":"web","readinessProbe":{"httpGet":{"path":"/ready","port":"http"},"periodSeconds":3}}]}}}}'
```

The probe now uses the port name `http`, which is container port 8080. The change creates new pods that become ready.

## Step 3. Find why dock restarts

```sh
kubectl -n starfleet describe pod -l app=dock
```

The events show failed liveness probes and a restart, and the pods restart again and again. The liveness probe starts 5 seconds after the container and kills it after about 10 more seconds, while the application needs 30 seconds to listen.

## Step 4. Add a startup probe to dock

```sh
kubectl -n starfleet patch deployment dock --patch '{"spec":{"template":{"spec":{"containers":[{"name":"web","startupProbe":{"httpGet":{"path":"/health","port":"http"},"periodSeconds":5,"failureThreshold":24}}]}}}}'
```

The startup probe runs every 5 seconds and allows 24 failures, so the budget is 5 x 24 = 120 seconds. The liveness and readiness probes do not run until the startup probe succeeds.

## Step 5. Add probes to keel

```sh
kubectl -n starfleet patch deployment keel --patch '{"spec":{"template":{"spec":{"containers":[{"name":"web","readinessProbe":{"tcpSocket":{"port":"http"},"periodSeconds":3},"livenessProbe":{"httpGet":{"path":"/health","port":"http"},"periodSeconds":10,"failureThreshold":3}}]}}}}'
```

## Step 6. Record the findings

```sh
kubectl -n starfleet create configmap probe-report \
  --from-literal=hail-wrong-port=8081 \
  --from-literal=dock-startup-seconds=120
```

## Step 7. Wait and submit

```sh
kubectl -n starfleet rollout status deployment/hail
kubectl -n starfleet rollout status deployment/dock
kubectl -n starfleet rollout status deployment/keel
astrona submit --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-020/capstone/labs/lab-01
```

`solution/apply.sh` applies the same changes.
