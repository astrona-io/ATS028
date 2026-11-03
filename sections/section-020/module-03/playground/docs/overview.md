# Probe Timing Playground

A single-node kind cluster (Kubernetes 1.35) with a fast application and a slow one. Nothing is graded.

## What is in the cluster

| Object | Namespace | Purpose |
| --- | --- | --- |
| Deployment `probe` (2 replicas) | `starfleet` | Starts at once. HTTP readiness probe on `/ready` and liveness probe on `/health` |
| Deployment `slow` (1 replica) | `starfleet` | Waits 30 seconds (`START_DELAY=30`) before it listens. Only a readiness probe |
| Services `probe` and `slow` | `starfleet` | Port 80 to the container port named `http` |
| Pods `shuttle` and `drifter` | `starfleet`, `outpost` | BusyBox clients |
| ConfigMap `probe-code` | `starfleet` | The Python server |

Marker files in a container change the answers: `/tmp/not-ready` makes `/ready` return 503, and `/tmp/unhealthy` makes `/health` return 503.

## Things to try

1. Watch `kubectl -n starfleet get pods -w` while you create `/tmp/unhealthy` in a `probe` pod and measure the time until the restart. Compare with `failureThreshold` times `periodSeconds`.
2. Add a liveness probe with `initialDelaySeconds: 5`, `periodSeconds: 5` and `failureThreshold: 2` to `slow`. Watch it loop.
3. Add a startup probe with a budget of 120 seconds and watch the loop end.
4. Lower the startup `failureThreshold` to 3 and read the `Startup probe failed` event.
5. Change `timeoutSeconds` and `successThreshold` on a readiness probe and watch the endpoints.
