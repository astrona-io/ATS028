# Task: Repair And Add Probes On Three Workloads

The namespace `starfleet` runs three Deployments of the same web application. It serves `/`, `/ready` and `/health` on container port 8080 (port name `http`). The client pod `shuttle` has `wget` for requests to `http://hail`, `http://dock` and `http://keel`.

## Requirements

1. The Deployment `hail` has 2 replicas, and none of them become ready. Find the cause in the pod events and fix the readiness probe. Keep it an HTTP probe on a path that the application serves.
2. The Deployment `dock` has 2 replicas that restart in a loop. The application needs about 30 seconds before it listens on port 8080. Add a startup probe to the `web` container that gives the application at least 60 seconds and at most 300 seconds to start, on the port named `http`. Keep the liveness probe, with a `periodSeconds` of 10 or less and a `failureThreshold` of 3 or less. Do not lengthen it to survive the start.
3. The Deployment `keel` has no probes. Add a readiness probe that uses the `tcpSocket` handler on the port named `http`, and a liveness probe that uses the `httpGet` handler on the path `/health` and the port named `http`.
4. Create the ConfigMap `probe-report` in `starfleet` with two keys. `hail-wrong-port` is the port that the failing readiness probe of `hail` used, read from the events. `dock-startup-seconds` is the startup budget of your probe for `dock` in seconds.
5. Wait until `hail` and `dock` have 2 ready replicas and `keel` has 1 ready replica, and no `dock` or `keel` container has restarted. Change nothing else: not the labels, the ports or the Services.

## How to check your work

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-020/capstone/labs/lab-01
```

Each check prints PASS or a FAIL line that names the difference. Fix it and submit again.
