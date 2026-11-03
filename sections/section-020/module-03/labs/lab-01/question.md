# Size A Startup Probe

The Deployment `beacon` in namespace `starfleet` runs an application that needs up to 45 seconds before it listens on port 8080 (port name `http`). The pods restart in a loop.

## Task

1. Find out why the pods restart. Use the pod events.
2. Add a startup probe to the `web` container that gives the application at least 60 seconds and at most 300 seconds to start. It must be an HTTP or TCP probe on the port named `http`.
3. Keep the liveness probe, with a `periodSeconds` of 10 or less and a `failureThreshold` of 3 or less. Do not lengthen it to survive the start.
4. Create the ConfigMap `probe-budget` in `starfleet` with the key `startup-seconds`. Its value is the startup budget of your probe in seconds.
5. Wait until `beacon` has 2 ready replicas and no container restarts.

## Notes

- `shuttle` in `starfleet` has `wget` for requests to `http://beacon`.
- Submit with `astrona submit`.
