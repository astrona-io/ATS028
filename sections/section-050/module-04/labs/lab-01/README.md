---
estimated_duration: 25m
---

# Lab: Diagnose And Repair Five Failing Workloads

Read the status and events of five failing workloads, record the cause of each and repair each with one change. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED - authored without running the lab.** The scripts passed static checks only (`astrona validate`, `bash -n`). Run `astrona test` before you rely on them.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-050/module-03/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-050/module-03/labs/lab-01
astrona destroy ats-028-lab-050-04-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-ensign-running.sh` | The ensign Deployment runs with an image that can be pulled |
| `validate-cadet-running.sh` | The cadet Deployment runs and still reads its setting from cadet-settings |
| `validate-captain-scheduled.sh` | The captain pod is scheduled with a CPU request of 1 core or less |
| `validate-engine-stable.sh` | The engine pod runs without restarts and keeps a memory limit of at least 192Mi |
| `validate-bridge-serving.sh` | A request from shuttle to http://bridge returns bridge-ok |
| `validate-triage-report.sh` | The ConfigMap triage-report names the cause of each fault |
