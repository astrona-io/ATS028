---
draft: true
exam_objectives:
- Utilize container logs
---
# Read Current And Previous Container Logs

The practice Pod prints a message and then exits with a nonzero status. Kubernetes restarts it under the default Pod restart policy. You will compare current logs, previous-container logs and termination evidence without assuming that one log line explains the entire failure.

Use the module playground and its private kubeconfig. The context check below prevents commands from being directed at an unrelated cluster. The helper retries a command for a bounded interval after controller or policy changes; it cannot turn a persistent failure into success. Read the actual errors when the interval expires.

<!-- astrona:playground:renew -->

For a timed catalog session, renew this module before continuing. Skip renewal for an untimed local author run:

```sh
astrona run renew astrona-io/ATS028/section-040/module-01/playground
```

Select the module environment and define a bounded retry helper:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-028-playground-040-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-028-playground-040-01"
kubectl -n starfleet get pods
wait_for_success() {
  for attempt in 1 2 3 4 5 6 7 8 9 10; do
    if "$@"; then return 0; fi
    sleep 1
  done
  return 1
}
```

Save the failing Pod and wait until a restart has actually occurred.

Save this as `pod-crash-report.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: crash-report
  namespace: starfleet
spec:
  containers:
  - name: report
    image: docker.io/library/busybox:1.37.0
    command:
    - sh
    - -c
    - printf "application-started\n"; sleep 2; exit 12
```

Apply or use the saved input, then check the result:

```sh
kubectl apply -f pod-crash-report.yaml
kubectl -n starfleet wait --for=jsonpath='{.status.containerStatuses[0].restartCount}'=1 pod/crash-report --timeout=60s
```

The process exit and restart are different observations. The Pod name remains stable while the container instance changes. Read the reported exit status rather than guessing from the application message.

Select the report container explicitly and request the previous instance with timestamps.

```sh
kubectl -n starfleet logs crash-report -c report --previous --timestamps
kubectl -n starfleet describe pod crash-report
kubectl -n starfleet get pod crash-report -o yaml
```

Previous logs exist only when a previous container instance and its available log data exist. They are not arbitrary historical retention. The last termination state supplies evidence distinct from message content.

Inspect a successful application log and remove the intentional failure.

```sh
wait_for_success kubectl -n starfleet exec shuttle -- wget -qO- http://probe/
kubectl -n starfleet logs deployment/probe --tail=10 --timestamps
kubectl -n starfleet delete pod crash-report
```

A generated request gives the server a reason to write access evidence. Deleting the failure Pod stops this exercise; deleting a controller-managed Pod would normally trigger replacement instead.

Correlate container identity, time and exit state. A familiar log message can be emitted before a later failure, and a container can fail before it produces any logs. Preserve the distinction when diagnosing preparation, startup and application errors.

## Common pitfalls

> [!WARNING]
> Keep the selected module context and inspect the observed outcome. Resource acceptance does not establish readiness or a successful request. Reset this isolated environment if earlier experiments changed the required starting state.
