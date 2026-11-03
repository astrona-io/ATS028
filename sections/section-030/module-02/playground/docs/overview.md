# Playground: Selecting And Shaping kubectl Output

A single-node kind cluster running Kubernetes 1.35 with the metrics-server add-on enabled. Nothing is graded.

## What is in the cluster

| Object | Namespace | Notes |
| --- | --- | --- |
| Deployment `probe` | `starfleet` | 2 pods, labels `app=probe`, `tier=web`, `env=prod` |
| Deployment `beacon` | `starfleet` | 1 pod, labels `app=beacon`, `tier=worker`, `env=prod` |
| Deployment `scout` | `starfleet` | 1 pod, labels `app=scout`, `tier=web`, `env=staging` |
| Service `probe` | `starfleet` | Port 80 to the `probe` pods |
| Job `report-job` | `starfleet` | Finished; its pod is in phase `Succeeded` |
| Pod `shuttle` | `starfleet` | Client with `wget` |
| Pod `drifter` | `outpost` | Client in a second namespace |

## Things to try

- List pods with `--show-labels`, then select with `-l tier=web`, `-l 'env in (prod,staging)'` and `-l '!reviewed'`.
- Select with `--field-selector=status.phase=Succeeded` and `--field-selector=spec.nodeName=<node>`.
- Print only names with `-o name`, a custom table with `-o custom-columns`, and a single field with `-o jsonpath`.
- Sort with `--sort-by=.metadata.creationTimestamp` and `--sort-by=.status.startTime`.
- Run `kubectl top pods -n starfleet` and `kubectl top nodes`. The first call can fail for about a minute until metrics-server has collected a sample.
