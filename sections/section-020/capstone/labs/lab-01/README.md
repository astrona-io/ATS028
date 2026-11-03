---
estimated_duration: 45m
---

# Capstone: Implement Probes And Health Checks

You repair a readiness probe, size a startup probe for a slow application and add readiness and liveness probes with different handlers to a workload that has none. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED - authored without running the lab.** The scripts passed static checks only (`astrona validate`, `bash -n`). Run `astrona test` before you rely on them.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-020/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-020/capstone/labs/lab-01
astrona destroy ats-028-capstone-020
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-hail-ready.sh` | hail keeps an HTTP readiness probe on the application port and has 2 ready replicas |
| `validate-dock-startup-probe.sh` | dock has a startup probe of 60 to 300 seconds and a quick liveness probe |
| `validate-dock-stable.sh` | dock has 2 ready replicas and no restarts |
| `validate-keel-probes.sh` | keel has a TCP readiness probe and an HTTP liveness probe on /health |
| `validate-keel-ready.sh` | keel is ready with the new probes and no restarts |
| `validate-probe-report.sh` | probe-report records the failing port and the startup budget |
| `validate-services-answer.sh` | The hail, dock and keel Services answer shuttle |
