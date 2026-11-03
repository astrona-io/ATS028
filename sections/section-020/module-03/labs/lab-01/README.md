---
estimated_duration: 25m
---

# Lab: Size A Startup Probe

Stop a restart loop on a slow application with a startup probe and record the startup budget. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED - authored without running the lab.** The scripts passed static checks only (`astrona validate`, `bash -n`). Run `astrona test` before you rely on them.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-020/module-03/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-020/module-03/labs/lab-01
astrona destroy ats-028-lab-020-03-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-startup-probe.sh` | beacon has a startup probe on port 8080 with a budget of 60 to 300 seconds |
| `validate-liveness-kept-fast.sh` | The liveness probe is kept, with a period of 10 seconds or less and at most 3 failures |
| `validate-beacon-stable.sh` | beacon has 2 ready replicas and no restarts |
| `validate-budget-recorded.sh` | The ConfigMap probe-budget records the startup budget in seconds |
| `validate-beacon-serving.sh` | beacon answers through its Service |
