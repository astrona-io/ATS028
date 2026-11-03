# Playground: Logging Architecture And Sidecars

A single-node kind cluster running Kubernetes 1.35. Nothing is graded.

## What is in the cluster

| Object | Namespace | Notes |
| --- | --- | --- |
| Deployment `stdout-app` | `starfleet` | 1 pod, container `app` prints `stdout-event` lines to standard output every 3 seconds |
| Deployment `file-app` | `starfleet` | 1 pod, container `app` appends `file-event` lines to `/var/log/app/app.log`; `kubectl logs` shows nothing |
| Deployment `sidecar-app` | `starfleet` | 1 pod, container `app` appends `sidecar-event` lines to the same file on an `emptyDir` volume; container `log-tail` prints the file |

## Things to try

- Read `kubectl -n starfleet logs deploy/stdout-app`, then `deploy/file-app`, and compare.
- Read the file with `kubectl -n starfleet exec deploy/file-app -- tail -n 3 /var/log/app/app.log`.
- Read `deploy/sidecar-app` with `-c app` and with `-c log-tail`.
- Print the volumes of `sidecar-app` with `-o jsonpath='{.spec.template.spec.volumes}'`.
- Start a shell on the node with `kubectl debug node/<node> -it --image=docker.io/library/busybox:1.37.0` and list `/host/var/log/pods` and `/host/var/log/containers`.
- Delete the `stdout-app` pod and read the log of the replacement.
