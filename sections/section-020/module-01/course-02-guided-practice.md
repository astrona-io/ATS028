---
draft: true
exam_objectives:
- Implement probes and health checks
---
# Distinguish Readiness Removal From Liveness Restart

The probe server has independent readiness and liveness marker files. Creating the readiness marker makes /ready fail, while creating the liveness marker makes /health fail. You will observe endpoint eligibility and restart count separately so the two recovery actions are not confused.

Use the module playground and its private kubeconfig. The context check below prevents commands from being directed at an unrelated cluster. The helper retries a command for a bounded interval after controller or policy changes; it cannot turn a persistent failure into success. Read the actual errors when the interval expires.

The application fixture has separate readiness and health paths. Creating the readiness marker changes traffic eligibility; creating the health marker affects liveness only after a liveness probe is configured. The existence of a response path alone does not install that probe.

Observe readiness, endpoint conditions and restart counts separately. The kubelet performs probes, and the backend controller reflects Pod readiness for Service traffic. A restarted container can remove a temporary marker in its writable layer, so that transient state does not behave like durable configuration.

<!-- astrona:playground:renew -->

For a timed catalog session, renew this module before continuing. Skip renewal for an untimed local author run:

```sh
astrona run renew astrona-io/ATS028/section-020/module-01/playground
```

Select the module environment and define a bounded retry helper:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-028-playground-020-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-028-playground-020-01"
kubectl -n starfleet get pods
wait_for_success() {
  for attempt in 1 2 3 4 5 6 7 8 9 10; do
    if "$@"; then return 0; fi
    sleep 1
  done
  return 1
}
```

Enable a liveness probe and reduce the workload to one replica for an unambiguous experiment. Wait for the new template, then capture the current Pod name.

```sh
kubectl -n starfleet patch deployment probe --type=strategic -p '{"spec":{"template":{"spec":{"containers":[{"name":"probe","livenessProbe":{"httpGet":{"path":"/health","port":"http"},"periodSeconds":2,"failureThreshold":3}}]}}}}'
kubectl -n starfleet scale deployment/probe --replicas=1
kubectl -n starfleet rollout status deployment/probe --timeout=120s
PROBE_POD=$(kubectl -n starfleet get pods -l app=probe -o jsonpath='{.items[0].metadata.name}')
```

Capture the name after rollout convergence. A Pod from an old ReplicaSet would be the wrong subject for the next observations.

Make readiness fail, wait for the observed condition and inspect Service endpoints. Then clear the marker and wait for readiness to recover.

```sh
kubectl -n starfleet exec "$PROBE_POD" -- touch /tmp/not-ready
kubectl -n starfleet wait --for=condition=Ready=false pod/"$PROBE_POD" --timeout=30s
kubectl -n starfleet get endpointslice -l kubernetes.io/service-name=probe -o yaml
kubectl -n starfleet exec "$PROBE_POD" -- rm /tmp/not-ready
kubectl -n starfleet wait --for=condition=Ready pod/"$PROBE_POD" --timeout=30s
```

Readiness changes eligibility without requiring a restart. Inspect the container restart count to confirm that you have not confused a process restart with endpoint removal.

Make liveness fail and wait for a restart-count change. The marker lives in the container filesystem, so a restarted container does not retain it.

```sh
kubectl -n starfleet exec "$PROBE_POD" -- touch /tmp/unhealthy
kubectl -n starfleet wait --for=jsonpath='{.status.containerStatuses[0].restartCount}'=1 pod/"$PROBE_POD" --timeout=60s
kubectl -n starfleet wait --for=condition=Ready pod/"$PROBE_POD" --timeout=60s
kubectl -n starfleet describe pod "$PROBE_POD"
```

The liveness failure should lead kubelet to restart the container under this Pod policy. A startup probe would gate other probes during initialization; it is a separate contract, not another name for readiness.

Use actual conditions and restart evidence, not only an HTTP failure, to identify the recovery action. Aggressive probes can create avoidable restart loops. This exercise uses controlled markers to expose the distinction without claiming production thresholds are appropriate.

## How long each recovery takes

The timing of both reactions follows from the probe fields. With `periodSeconds: 2` and `failureThreshold: 3`, the kubelet needs three failed checks in a row before it acts, so a liveness restart starts about six seconds after the marker appears. One successful check resets the count of consecutive failures. A readiness failure uses the same counting, but its result is different: the kubelet sets the `Ready` condition of the pod to `False`, and the endpoint controller then marks the address as not ready in the EndpointSlice. The container keeps running and its restart count does not change.

## What to compare in the output

Three values answer the question of which action happened:

- The `Ready` condition of the pod, which shows whether the pod is eligible for Service traffic.
- The `ready` field of the endpoint in the EndpointSlice, which shows whether the Service sends traffic to the pod.
- `restartCount` in `status.containerStatuses`, which grows only when the kubelet restarts the container.

After a readiness failure, the first two values change and the restart count stays the same. After a liveness failure, the restart count grows by one, and the `Ready` condition drops only for the short time that the new container needs to start. The `describe` output lists a `Liveness probe failed` event followed by a `Killing` event for the second case, and no such events for the first case.

## Common pitfalls

> [!WARNING]
> Keep the selected module context and inspect the observed outcome. Resource acceptance does not establish readiness or a successful request. Reset this isolated environment if earlier experiments changed the required starting state.
