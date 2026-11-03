# Probe Handlers Playground

A single-node kind cluster (Kubernetes 1.35) with a small web application, ready for probe experiments. Nothing is graded.

## What is in the cluster

| Object | Namespace | Purpose |
| --- | --- | --- |
| Deployment `probe` (2 replicas) | `starfleet` | Web application with an HTTP readiness probe on `/ready` and an HTTP liveness probe on `/health` |
| Deployment `beacon` (1 replica) | `starfleet` | Same application with only a liveness probe |
| Service `probe` and Service `beacon` | `starfleet` | Port 80 to the container port named `http` |
| Pod `shuttle` | `starfleet` | BusyBox client for requests inside the namespace |
| Pod `drifter` | `outpost` | BusyBox client from another namespace |
| ConfigMap `probe-code` | `starfleet` | The Python server the Deployments run |

The application answers on port 8080 with `/`, `/ready` and `/health`. Every other path returns status 404. If the file `/tmp/not-ready` exists in a container, `/ready` returns 503. If `/tmp/unhealthy` exists, `/health` returns 503.

## Things to try

1. Print the probes of the `probe` Deployment with `kubectl -n starfleet get deployment probe -o yaml`.
2. Create `/tmp/not-ready` in one pod with `kubectl -n starfleet exec <pod> -- touch /tmp/not-ready`. Watch the pod leave the Service endpoints with `kubectl -n starfleet get endpointslices`.
3. Create `/tmp/unhealthy` and watch the container restart.
4. Add an `exec` probe that runs `wget -q -T 2 -O /dev/null http://127.0.0.1:8080/health`.
5. Change a probe port to 9090 and read the event text.
