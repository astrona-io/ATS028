---
draft: true
exam_objectives:
- Implement probes and health checks
---
# Summary

Probe timing decides when a container is restarted or removed from a Service. A startup probe protects slow starts without slowing failure detection later.

## Key points

- Every probe has `initialDelaySeconds` (default 0), `periodSeconds` (10), `timeoutSeconds` (1), `successThreshold` (1) and `failureThreshold` (3).
- A counter of consecutive results changes the state. One failure among successes changes nothing.
- A failing liveness probe restarts the container after about `failureThreshold` times `periodSeconds`.
- A failing readiness probe removes the pod from the Service endpoints and never restarts the container.
- A liveness probe that fires before a slow application listens creates a restart loop without any application bug.
- A startup probe disables liveness and readiness probes until it succeeds once. If it fails `failureThreshold` times, the container is restarted.
- The startup budget is `initialDelaySeconds` plus `failureThreshold` times `periodSeconds`.

## Commands to remember

| Command | Purpose |
| --- | --- |
| `kubectl describe pod <name>` | Read `Unhealthy` and `Killing` events |
| `kubectl get events --field-selector reason=Unhealthy` | List probe failures in a namespace |
| `kubectl patch deployment <name> --patch-file <file>` | Add or change a probe |
| `kubectl get pod <name> -o jsonpath='{.spec.containers[0].startupProbe}'` | Print the startup probe with defaults |

## Next step

Run the graded lab for this module. A Deployment restarts in a loop because its liveness probe is earlier than its start. You add a startup probe and record the budget.

<!-- astrona:playground:destroy -->
