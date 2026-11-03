# Playground: Rollouts, Events And Watching Change

A single-node kind cluster running Kubernetes 1.35. Nothing is graded.

## What is in the cluster

| Object | Namespace | Notes |
| --- | --- | --- |
| Deployment `probe` | `starfleet` | 2 pods, `VERSION=v1`, readiness probe on `/ready` |
| Deployment `beacon` | `starfleet` | 2 pods, `VERSION=v1`, readiness probe on `/ready` |
| Service `probe` | `starfleet` | Port 80 to the `probe` pods |
| Pod `shuttle` | `starfleet` | Client with `wget` |
| Pod `drifter` | `outpost` | Client in a second namespace |

## Things to try

- Update `beacon` with `kubectl set env deployment/beacon VERSION=v2`, watch it with `kubectl rollout status`, then list the revisions with `kubectl rollout history`.
- Break a rollout on purpose with `kubectl set image deployment/beacon web=docker.io/library/python:does-not-exist`. Find the reason in `kubectl get events` and fix it with `kubectl rollout undo`.
- Watch pods change with `kubectl get pods -w` in a second terminal while you scale a Deployment.
- Pause a rollout with `kubectl rollout pause`, change two settings, then `kubectl rollout resume`.
- Print events sorted by time and filtered by object with `kubectl events --for pod/<name>`.
