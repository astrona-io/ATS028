---
estimated_duration: 40m
---

# Capstone: Debug A Release With Three Problems

Diagnose a readiness probe that checks the wrong port, an image that cannot be pulled and a running pod that you inspect from the inside. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED - authored without running the lab.** The scripts passed static checks only (`astrona validate`, `bash -n`). Run `astrona test` before you rely on them.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-050/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-050/capstone/labs/lab-01
astrona destroy ats-028-capstone-050
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-hail-serving.sh` | hail has 2 ready replicas and answers through its Service |
| `validate-hail-probe-kept.sh` | hail keeps an HTTP readiness probe |
| `validate-dock-running.sh` | dock runs with an image that can be pulled |
| `validate-beacon-findings.sh` | capstone-report holds the BUILD_ID and the listening port of beacon |
| `validate-beacon-inspected.sh` | beacon has the ephemeral container inspector and is the original pod |
| `validate-causes-recorded.sh` | capstone-report names the causes of the hail and dock faults |
