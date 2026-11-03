---
estimated_duration: 25m
---

# Lab: Ship A File Log To Standard Output With A Sidecar

You add a shared emptyDir volume and a tailing sidecar container so that kubectl logs shows a log that the application writes to a file. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED - authored without running the lab.** The scripts passed static checks only (`astrona validate`, `bash -n`). Run `astrona test` before you rely on them.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-040/module-03/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-040/module-03/labs/lab-01
astrona destroy ats-028-lab-040-03-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-sidecar-running.sh` | The ledger-writer pod runs two ready containers and one is named log-tail |
| `validate-shared-volume.sh` | Both containers mount the same emptyDir volume, and log-tail mounts it read-only |
| `validate-sidecar-streams-log.sh` | The log of the log-tail container contains the ledger-event lines |
| `validate-writer-unchanged.sh` | The writer container keeps its image and its file path, and the Deployment keeps 1 replica |
