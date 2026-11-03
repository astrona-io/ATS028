# Fix And Add Probe Handlers

Namespace `starfleet` holds a web application that serves `/`, `/ready` and `/health` on container port 8080 (port name `http`). Two Deployments use it.

## Task

1. The Deployment `beacon` has 2 replicas, and none of them become ready. Find out why from the pod events and fix the probes. Keep both probes. The readiness probe must be an HTTP check on a path the application serves. The liveness probe must check container port 8080.
2. The Deployment `scout` has no probe. Add a readiness probe that uses the `exec` handler. The command must run inside the container and must exit with code 0 only when the application answers. Do not change labels, ports or the Service.
3. Wait until `beacon` has 2 ready replicas and `scout` has 1 ready replica, and no beacon container has restarted.

## Notes

- The client pod `shuttle` in `starfleet` has `wget` for requests to `http://beacon` and `http://scout`.
- You may use `kubectl edit`, `kubectl patch` or a manifest.
- Submit with `astrona submit`.
