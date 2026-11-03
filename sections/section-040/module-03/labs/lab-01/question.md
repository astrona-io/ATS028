# Task: Ship A File Log To Standard Output With A Sidecar

The Deployment `ledger-writer` in the namespace `starfleet` runs one container named `writer`. It appends `ledger-event` lines to `/var/log/app/app.log` and prints nothing to standard output, so `kubectl logs` is empty. The application cannot be changed. Make its log readable with `kubectl logs` by adding a streaming sidecar.

## Requirements

1. Add an `emptyDir` volume to the pod template of `ledger-writer`.
2. Mount the volume at `/var/log/app` in the `writer` container.
3. Add a second container named `log-tail` that uses the image `docker.io/library/busybox:1.37.0`, mounts the same volume at `/var/log/app` with `readOnly: true`, and prints the file with `tail -n+1 -F /var/log/app/app.log`.
4. Keep the `writer` container as it is: same image, same command, same file path. The Deployment keeps 1 replica.
5. Wait until the rollout finishes. `kubectl -n starfleet logs deploy/ledger-writer -c log-tail` must show `ledger-event` lines.

## How to check your work

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-040/module-03/labs/lab-01
```

Each check prints PASS or a FAIL line that names the difference. Fix it and submit again.
