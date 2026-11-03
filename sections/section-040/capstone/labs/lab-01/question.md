# Task: Read Container Logs And Add A Log Sidecar

The namespace `starfleet` runs three Deployments. `manifest` runs three pods, and each pod has two containers named `web` and `audit`. `valve` runs one pod that stops soon after it starts and is restarted. `gauge` runs one container named `writer` that appends `gauge-reading` lines to `/var/log/gauge/gauge.log` and prints nothing to standard output. The `gauge` application cannot be changed.

Collect the facts below with `kubectl logs` and `kubectl get`, store them in a ConfigMap, and make the `gauge` log readable with `kubectl logs`.

## Requirements

1. The `audit` container of the `manifest` Deployment prints a line that contains `ERROR code=` followed by an error code. Read only that container. Do not guess the code, because it changes every time the lab starts.
2. The container of the `valve` pod stops quickly. Its message names an environment variable that is not set. Read the log of the previous run and find the name of that variable.
3. Count the pods of the `manifest` Deployment, and list the container names of its pod template, sorted by name and separated by a comma without spaces.
4. Create the ConfigMap `log-report` in the namespace `starfleet` with these four keys: `audit-code` (the error code, for example `E123`), `valve-key` (the variable name), `pods` (the number of pods) and `containers` (the sorted container names).
5. Add an `emptyDir` volume to the pod template of `gauge`. Mount it at `/var/log/gauge` in the `writer` container.
6. Add a second container named `log-tail` to the `gauge` pod template. It uses the image `docker.io/library/busybox:1.37.0`, mounts the same volume at `/var/log/gauge` with `readOnly: true`, and prints the file with `tail -n+1 -F /var/log/gauge/gauge.log`.
7. Keep the `writer` container, the `manifest` Deployment and the `valve` Deployment as they are. The `gauge` Deployment keeps 1 replica. Wait until the rollout finishes, and check that `kubectl -n starfleet logs deploy/gauge -c log-tail` shows `gauge-reading` lines.

## How to check your work

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-040/capstone/labs/lab-01
```

Each check prints PASS or a FAIL line that names the difference. Fix it and submit again.
