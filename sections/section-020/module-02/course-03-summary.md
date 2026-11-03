---
draft: true
exam_objectives:
- Implement probes and health checks
---
# Summary

A probe handler is the mechanism the kubelet uses to ask one container a health question. Kubernetes has four handlers, and each succeeds under a different rule.

## Key points

- The kubelet on the node runs every probe. For `httpGet`, `tcpSocket` and `grpc` it connects to the pod IP and the container port. A Service plays no role.
- `httpGet` succeeds for status codes from 200 up to and below 400. A 404 or 503 is a failure, and a redirect is a success.
- `tcpSocket` succeeds when the connection opens. It proves a listener exists, not that the application answers correctly.
- `exec` succeeds when the command exits with code 0. The command is a list, not a shell line, and it needs its program inside the image.
- `grpc` succeeds when the gRPC health service answers `SERVING`. It needs a numeric port and a server that implements the health service.
- Use a named container port in `httpGet` and `tcpSocket` so the probe follows the port number.

## Reading the events

| Event text | Meaning |
| --- | --- |
| `HTTP probe failed with statuscode: 404` | The application is up and the path is wrong |
| `HTTP probe failed with statuscode: 503` | The application reports itself unhealthy |
| `connect: connection refused` | Nothing listens on the probed port |
| `Readiness probe errored` | The probe itself could not run, for example a missing executable |

## Commands to remember

| Command | Purpose |
| --- | --- |
| `kubectl describe pod <name>` | Show probe settings and the `Unhealthy` events |
| `kubectl get pod -o jsonpath='{.spec.containers[0].readinessProbe}'` | Print one probe |
| `kubectl exec <pod> -- <command>` | Run the same check by hand |
| `kubectl patch deployment <name> --patch-file <file>` | Change a probe through the pod template |

## Next step

Run the graded lab for this module. It contains a Deployment with a wrong HTTP path and a wrong liveness port, and a Deployment that needs an exec probe.

<!-- astrona:playground:destroy -->
