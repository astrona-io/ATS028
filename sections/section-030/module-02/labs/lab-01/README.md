---
estimated_duration: 25m
---

# Lab: Select And Report Workloads

Select pods with label and field selectors, shape the output, and record the answers in a ConfigMap. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED - authored without running the lab.** The scripts passed static checks only (`astrona validate`, `bash -n`). Run `astrona test` before you rely on them.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-030/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-030/module-02/labs/lab-01
astrona destroy ats-028-lab-030-02-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-web-pods-recorded.sh` | The ConfigMap findings key web-pods lists the production web pods |
| `validate-images-recorded.sh` | The ConfigMap findings key images lists the distinct container images in starfleet |
| `validate-completed-pod-recorded.sh` | The ConfigMap findings key completed-pod names the pod that finished |
| `validate-web-pods-labeled.sh` | Every production web pod carries the label reviewed=true and no other pod does |
| `validate-app-still-serving.sh` | The probe application still answers through its Service |
