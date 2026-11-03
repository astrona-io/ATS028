# Playground: Multi-Container And Multi-Pod Logs

A single-node kind cluster running Kubernetes 1.35. Nothing is graded.

## What is in the cluster

| Object | Namespace | Notes |
| --- | --- | --- |
| Deployment `multi` | `starfleet` | 3 pods, label `app=multi`, containers `web` and `worker` |
| Deployment `flaky` | `starfleet` | 1 pod, label `app=flaky`, container `app` that exits with code 1 on every start |

The `web` container prints `web request=N status=200` every two seconds. The `worker` container prints `worker job=N state=done` every two seconds and a `worker ERROR job=N retry=1` line on every fifth job. The `flaky` container prints `boot step=1 starting`, then `fatal: cannot open /etc/flaky/config.yaml` on standard error, and exits.

## Things to try

- Run `kubectl -n starfleet logs <pod>` without `-c` and read the default-container notice, then add `-c worker` and `--all-containers --prefix`.
- Compare `kubectl logs deploy/multi -c web` with `kubectl logs -l app=multi -c web --prefix`.
- Run `kubectl logs -l app=multi -c worker --prefix` and count the lines per pod, then add `--tail=-1`.
- Use `--since=20s`, `--timestamps` and `| grep ERROR`.
- Follow with `-f`. Then follow `-l app=multi --all-containers` and add `--max-log-requests=6`.
- Read `kubectl -n starfleet logs deploy/flaky --previous`.
