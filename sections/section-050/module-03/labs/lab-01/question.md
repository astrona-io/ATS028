---
draft: true
exam_objectives:
- Debugging in Kubernetes
---
# Task: Inspect A Running Pod And Correct Its Service

The pod `scout` in the namespace `starfleet` runs a web server. Requests from the client pod `shuttle` to `http://scout` fail, and the pod itself shows `Running`. The owners say the application is fine. Check this from the inside of the container, record the facts, and correct the object that is wrong. Do not delete or recreate the pod.

## Requirements

1. Create a ConfigMap named `scout-findings` in `starfleet` with two keys:
   - `listen-port`: the TCP port on which the web server process in the container really listens. Read it from inside the container; do not copy it from the pod specification.
   - `app-version`: the value of the environment variable `APP_VERSION` as the container sees it.
2. Attach an ephemeral container named `inspector` to the pod `scout`. It must use the image `docker.io/library/busybox:1.37.0` and must target the container `app`.
3. Correct the Service `scout` so that a request from `shuttle` to `http://scout` succeeds. Keep the Service port 80 and the port name `http`.
4. The pod `scout` must stay the original pod: do not delete it, and do not let it restart.

## How to check your work

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-050/module-03/labs/lab-01
```

Each check prints PASS or a FAIL line that names the difference. Fix it and submit again.
