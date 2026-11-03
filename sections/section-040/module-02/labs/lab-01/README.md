---
estimated_duration: 20m
---

# Lab: Read Logs From Multi-Container And Crashing Pods

You select the right container in a multi-container Deployment, read the log of a crashed run and record what you found. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED - authored without running the lab.** The scripts passed static checks only (`astrona validate`, `bash -n`). Run `astrona test` before you rely on them.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-040/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-040/module-02/labs/lab-01
astrona destroy ats-028-lab-040-02-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-audit-code.sh` | The ConfigMap log-findings key audit-code holds the code printed by the audit container |
| `validate-fuse-key.sh` | The ConfigMap log-findings key fuse-key holds the variable named in the previous log of the fuse pod |
| `validate-containers-and-pods.sh` | The ConfigMap log-findings keys containers and pods match the ledger pods |
| `validate-workloads-unchanged.sh` | The ledger and fuse Deployments are not deleted or changed |
