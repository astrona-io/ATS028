# Playground: Diagnosing Failing Workloads From Status To Cause

A single-node kind cluster running Kubernetes 1.35. Nothing is graded.

## What is in the cluster

| Object | Namespace | Notes |
| --- | --- | --- |
| Deployment `probe` and Service `probe` | `starfleet` | A working web application |
| Deployment `ensign` | `starfleet` | Uses an image tag that does not exist |
| Deployment `cadet` | `starfleet` | Reads a key from the ConfigMap `cadet-settings`, which does not exist |
| Deployment `captain` | `starfleet` | Requests 64 CPU cores |
| Deployment `engine` | `starfleet` | Allocates about 150 MiB with a memory limit of 64 MiB |
| Deployment `bridge` and Service `bridge` | `starfleet` | Pod runs and answers on port 8080; the Service selector matches no pod |
| Pod `shuttle` | `starfleet` | Client with `wget` |
| Pod `drifter` | `outpost` | Client in a second namespace |

## Things to try

- Run `kubectl -n starfleet get pods` and name the stage that failed for each pod.
- Read the `Events` of each failing pod with `kubectl describe`.
- Read `lastState.terminated` of the `engine` pod with `-o jsonpath`.
- Compare `kubectl get endpoints bridge` with the pod labels and the Service selector.
- Correct each fault with one change and repeat the original check.
