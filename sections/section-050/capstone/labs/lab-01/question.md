---
draft: true
exam_objectives:
- Debugging in Kubernetes
---
# Task: Debug A Release With Three Problems

A release went out to the namespace `starfleet` and three things need attention. The Deployment `hail` (2 replicas) is never ready and its Service `hail` serves nothing. The Deployment `dock` does not start. The pod `beacon` runs a web server, and the release manager needs two facts from inside it. The Deployment `probe` and the pod `shuttle` are healthy and must not be changed.

## Requirements

1. Before you fix anything, create a ConfigMap named `capstone-report` in `starfleet` with these keys:
   - `hail`: the event reason that Kubernetes reports for the failing readiness probe of `hail`.
   - `dock`: the reason that Kubernetes reports for the pod of `dock`.
   - `beacon-build`: the value of the environment variable `BUILD_ID`, read from inside the container `app` of the pod `beacon`.
   - `beacon-port`: the TCP port on which the process in `beacon` listens, read from inside the container.
2. Repair `hail` so that it has 2 ready replicas and `http://hail` answers a request from `shuttle`. It must keep an HTTP readiness probe.
3. Repair `dock` so that its pod runs, with the smallest change.
4. Attach an ephemeral container named `inspector` (image `docker.io/library/busybox:1.37.0`, target container `app`) to the pod `beacon`. Do not delete or recreate `beacon`.

## How to check your work

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-050/capstone/labs/lab-01
```

Each check prints PASS or a FAIL line that names the difference. Fix it and submit again.
