---
estimated_duration: 40m
---

# Capstone: Utilize Container Logs

You read the logs of a multi-container Deployment and of a crashing container, record the facts in a ConfigMap, and add a sidecar that makes a file log readable with kubectl logs. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED - authored without running the lab.** The scripts passed static checks only (`astrona validate`, `bash -n`). Run `astrona test` before you rely on them.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-040/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-040/capstone/labs/lab-01
astrona destroy ats-028-capstone-040
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-audit-code.sh` | `log-report` key `audit-code` equals the code in the audit container log |
| `validate-valve-key.sh` | `log-report` key `valve-key` equals the variable named in the valve log |
| `validate-pods-and-containers.sh` | `log-report` keys `pods` and `containers` match the manifest Deployment |
| `validate-sidecar-running.sh` | The gauge pod runs two ready containers and one is named log-tail |
| `validate-shared-volume.sh` | Both containers mount the same emptyDir volume, and log-tail mounts it read-only |
| `validate-sidecar-streams-log.sh` | The log of the log-tail container contains gauge-reading lines |
| `validate-workloads-unchanged.sh` | The writer container and the other Deployments keep their settings |
