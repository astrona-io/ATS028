---
estimated_duration: 25m
---

# Lab: Inspect A Running Pod And Correct Its Service

Read the real listening port and environment from inside a running pod, attach an ephemeral container and correct a Service that points at the wrong port. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED - authored without running the lab.** The scripts passed static checks only (`astrona validate`, `bash -n`). Run `astrona test` before you rely on them.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-050/module-03/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-050/module-03/labs/lab-01
astrona destroy ats-028-lab-050-03-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-listen-port-recorded.sh` | The ConfigMap scout-findings key listen-port holds the port the process listens on |
| `validate-app-version-recorded.sh` | The ConfigMap scout-findings key app-version holds the value of APP_VERSION read from the container |
| `validate-ephemeral-container-attached.sh` | The pod scout has an ephemeral container named inspector that targets the container app |
| `validate-service-reachable.sh` | A request from the pod shuttle to http://scout succeeds |
| `validate-scout-pod-unchanged.sh` | The pod scout is the original pod and has not restarted |
