---
estimated_duration: 25m
---

# Lab: Diagnose And Roll Back A Stuck Rollout

Find why a rollout is stuck from rollout status and events, record the evidence, roll back and annotate. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED - authored without running the lab.** The scripts passed static checks only (`astrona validate`, `bash -n`). Run `astrona test` before you rely on them.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-030/module-03/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-030/module-03/labs/lab-01
astrona destroy ats-028-lab-030-03-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-rolled-back.sh` | The beacon Deployment runs the working image on 2 ready replicas |
| `validate-failed-image-recorded.sh` | The ConfigMap rollout-report key failed-image names the image of the failed revision |
| `validate-reason-recorded.sh` | The ConfigMap rollout-report key reason holds the waiting reason of the failed pod |
| `validate-change-cause-set.sh` | The beacon Deployment carries a new change-cause annotation |
| `validate-probe-untouched.sh` | The probe Deployment was not changed |
