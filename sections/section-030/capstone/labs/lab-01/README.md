---
estimated_duration: 40m
---

# Capstone: Monitor Applications With Built-In kubectl Tools

You select pods with labels, find a restarting pod, collect the evidence of a stuck rollout, roll it back and document the change. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED - authored without running the lab.** The scripts passed static checks only (`astrona validate`, `bash -n`). Run `astrona test` before you rely on them.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-030/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-030/capstone/labs/lab-01
astrona destroy ats-028-capstone-030
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-report-pods.sh` | `prod-web-pods` lists exactly the pods with tier=web and env=prod |
| `validate-report-restarting-pod.sh` | `restarting-pod` names a pod with a restart count above 0 |
| `validate-report-rollout.sh` | `failed-image` and `reason` match the failed revision of dock |
| `validate-dock-rolled-back.sh` | dock runs the previous image, keeps its history and has a new change-cause |
| `validate-reviewed-labels.sh` | `reviewed=true` is on exactly the env=prod pods |
| `validate-workloads-untouched.sh` | hail and keel keep revision 1 and 2 ready replicas |
