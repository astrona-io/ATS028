---
estimated_duration: 25m
---

# Lab: Migrate Ingress, CronJob, HorizontalPodAutoscaler And PodDisruptionBudget

Rewrite four definitions that use removed API versions so that the cluster accepts them, without changing the running application. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED - authored without running the lab.** The scripts passed static checks only (`astrona validate`, `bash -n`). Run `astrona test` before you rely on them.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-010/module-03/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-010/module-03/labs/lab-01
astrona destroy ats-028-lab-010-03-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-ingress-migrated.sh` | The Ingress probe-edge is stored in networking.k8s.io/v1 with the class field, a path type and a service backend |
| `validate-cronjob-migrated.sh` | The CronJob shuttle-sweep is stored in batch/v1 with its schedule and policy kept |
| `validate-hpa-migrated.sh` | The HorizontalPodAutoscaler probe-scaler is stored in autoscaling/v2 with a Utilization target of 55 |
| `validate-pdb-migrated.sh` | The PodDisruptionBudget probe-budget is stored in policy/v1 and selects the probe pods |
| `validate-probe-still-serving.sh` | The probe application still answers through its Service |
