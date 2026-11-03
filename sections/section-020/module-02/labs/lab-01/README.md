---
estimated_duration: 25m
---

# Lab: Fix And Add Probe Handlers

Repair two broken probes on a Deployment and add an exec probe to a second Deployment. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED - authored without running the lab.** The scripts passed static checks only (`astrona validate`, `bash -n`). Run `astrona test` before you rely on them.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-020/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-020/module-02/labs/lab-01
astrona destroy ats-028-lab-020-02-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-beacon-ready.sh` | The beacon Deployment has 2 ready replicas |
| `validate-beacon-probes-kept.sh` | beacon keeps both probes and they target the working endpoints |
| `validate-beacon-stable.sh` | The running beacon pods have not restarted |
| `validate-scout-exec-probe.sh` | scout has an exec readiness probe that checks the application and the pod is ready |
| `validate-scout-still-serving.sh` | The scout Service still answers through its endpoints |
