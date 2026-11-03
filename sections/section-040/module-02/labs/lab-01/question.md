# Task: Read Logs From Multi-Container And Crashing Pods

The namespace `starfleet` runs two Deployments. The `ledger` Deployment has three pods with two containers each, and one container prints an error code. The `fuse` Deployment is in a crash loop. A teammate needs the findings written down. Read the logs and do not change the workloads.

## Requirements

1. In the `ledger` pods, the container `audit` prints a line with `ERROR code=...`. Find the code.
2. The pod of the `fuse` Deployment fails on every start. The run that already ended printed a line that starts with `fatal:` and names an environment variable. Find the variable name.
3. Count the pods that have the label `app=ledger`, and list the container names of a `ledger` pod.
4. Create a ConfigMap named `log-findings` in `starfleet` with these keys:
   - `audit-code`: the code from the `audit` container, for example `E123`.
   - `fuse-key`: the environment variable name from the log of the ended `fuse` run.
   - `pods`: the number of `ledger` pods.
   - `containers`: the container names of a `ledger` pod, sorted and separated by commas, with no spaces.
5. Do not delete, scale, edit or restart the `ledger` or `fuse` Deployment.

## How to check your work

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-040/module-02/labs/lab-01
```

Each check prints PASS or a FAIL line that names the difference. Fix it and submit again.
