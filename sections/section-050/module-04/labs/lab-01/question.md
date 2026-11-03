---
draft: true
exam_objectives:
- Debugging in Kubernetes
---
# Task: Diagnose And Repair Five Failing Workloads

After a change window, five workloads in the namespace `starfleet` do not work: the Deployments `ensign`, `cadet`, `captain` and `engine`, and the Service `bridge` in front of the Deployment `bridge`. The Deployment `probe` and the pod `shuttle` are healthy. Find the cause of each fault, record it, and repair it with the smallest change.

## Requirements

1. Before you fix anything, create a ConfigMap named `triage-report` in `starfleet` with these keys:
   - `ensign`, `cadet`, `engine`: the reason that Kubernetes reports for the pod (the waiting reason, or the termination reason of the previous run).
   - `captain`: the reason of the `PodScheduled` condition.
   - `bridge`: the label selector (`key=value`) that the Service `bridge` must use.
2. Make `ensign` run with an image that can be pulled.
3. Make `cadet` start. It must keep reading `MODE` from the ConfigMap `cadet-settings`.
4. Make `captain` schedule. Its CPU request must be 1 core or less.
5. Make `engine` run without restarts. It must keep a memory limit of at least `192Mi`.
6. Make the Service `bridge` deliver requests: `http://bridge` from the pod `shuttle` must return `bridge-ok`. Do not change the pod labels.

## How to check your work

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-050/module-04/labs/lab-01
```

Each check prints PASS or a FAIL line that names the difference. Fix it and submit again.
