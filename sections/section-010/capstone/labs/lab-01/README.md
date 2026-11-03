---
estimated_duration: 40m
---

# Capstone: Handle API Deprecations

You discover the API versions that the cluster serves and migrate four legacy manifests (Deployment, CronJob, PodDisruptionBudget and HorizontalPodAutoscaler) without disturbing the application. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED - authored without running the lab.** The scripts passed static checks only (`astrona validate`, `bash -n`). Run `astrona test` before you rely on them.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-010/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-010/capstone/labs/lab-01
astrona destroy ats-028-capstone-010
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-relay-deployment.sh` | Deployment relay is served by apps/v1 with an explicit selector and 2 ready replicas |
| `validate-cronjob-migrated.sh` | CronJob beacon-sweep is served by batch/v1 with its policy kept |
| `validate-pdb-migrated.sh` | PodDisruptionBudget relay-budget is served by policy/v1 |
| `validate-hpa-migrated.sh` | HorizontalPodAutoscaler relay-scaler is served by autoscaling/v2 |
| `validate-api-audit.sh` | The ConfigMap api-audit records the served versions |
| `validate-relay-serving.sh` | The relay Service has 2 ready endpoints and answers the drifter pod |
| `validate-legacy-bundle-unchanged.sh` | The legacy-bundle and probe-code ConfigMaps are unchanged |
