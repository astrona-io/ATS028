---
draft: true
exam_objectives:
- Debugging in Kubernetes
---
# Locate Pending Placement And Repair A Node Selector

An intentionally unmatched node selector prevents the new Pod template from being scheduled. You will inspect Pending Pods and scheduler events, then remove only the unsupported selector. This separates placement from image preparation or an application process that has already started.

Use the module playground and its private kubeconfig. The context check below prevents commands from being directed at an unrelated cluster. The helper retries a command for a bounded interval after controller or policy changes; it cannot turn a persistent failure into success. Read the actual errors when the interval expires.

The deliberately created failure cases stop at different boundaries. An unschedulable request prevents node assignment, while an invalid image can fail after assignment. A corrected placement rule cannot repair a missing executable, and changing a process command cannot supply missing node capacity.

For each case, identify the last completed stage and inspect its responsible component. Read current events alongside the current specification so an old failed attempt does not become the explanation for a newer, corrected state.

<!-- astrona:playground:renew -->

For a timed catalog session, renew this module before continuing. Skip renewal for an untimed local author run:

```sh
astrona run renew astrona-io/ATS028/section-050/module-01/playground
```

Select the module environment and define a bounded retry helper:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-028-playground-050-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-028-playground-050-01"
kubectl -n starfleet get pods
wait_for_success() {
  for attempt in 1 2 3 4 5 6 7 8 9 10; do
    if "$@"; then return 0; fi
    sleep 1
  done
  return 1
}
```

Add a node selector that no node in this isolated cluster has.

```sh
kubectl -n starfleet patch deployment probe -p '{"spec":{"template":{"spec":{"nodeSelector":{"training.example/eligible":"missing"}}}}}'
kubectl get nodes --show-labels
kubectl -n starfleet get pods -l app=probe -o wide
```

A new template can create a Pending Pod while previous replicas remain ready. Inspect which ReplicaSet and Pod have the unmatched requirement before attributing all visible Pods to the same failure.

Collect placement evidence from Pods and events.

```sh
kubectl -n starfleet describe pods -l app=probe
kubectl -n starfleet get events --sort-by=.metadata.creationTimestamp
kubectl -n starfleet get replicasets -l app=probe
```

A scheduling event can identify a selector mismatch. It is earlier than image pulling and application startup, so changing readiness probes would not address this condition.

Remove the added field from authoritative workload input and observe the resulting rollout.

```sh
kubectl -n starfleet patch deployment probe --type=json -p '[{"op":"remove","path":"/spec/template/spec/nodeSelector"}]'
kubectl -n starfleet rollout status deployment/probe --timeout=120s
wait_for_success kubectl -n starfleet exec shuttle -- wget -qO- http://probe/
```

The repair creates a compatible template. It does not require weakening all cluster scheduling policy or repeatedly deleting Pods with the same unmatched selector.

Identify the first blocked lifecycle phase before changing unrelated fields. Pending placement, image download and a running process failure have different responsible components and evidence. This controlled case establishes the diagnosis method without fabricating scheduler output.

## Why the old pods stay while the new one is Pending

A Deployment with the rolling update strategy creates a new ReplicaSet for the changed template and scales it up while it scales the old one down. The new pod cannot be scheduled because of the selector, so it never becomes ready. The Deployment controller counts ready pods against `maxUnavailable`, and it stops removing old pods when removing more would go below the allowed availability. The result is one Pending pod from the new ReplicaSet next to the ready pods of the old one. This is why requests to the Service still work while the rollout does not finish, and why `rollout status` waits until its timeout.

## What the scheduler checks first

The scheduler filters nodes in steps. A node selector is checked as a filter: a node that does not carry every listed label is removed from the candidates. When no node is left, the scheduler writes the `FailedScheduling` event with the number of nodes that each filter rejected, and the pod stays unassigned. Removing the selector from the template creates a new ReplicaSet revision, and the new pod passes the filter. The old Pending pod is replaced because its ReplicaSet scales to zero.

## Other reasons for the same symptom

A node selector is one of several filters that leave a pod `Pending`. Node affinity rules, taints without a matching toleration, resource requests that no node can hold, and a PersistentVolumeClaim that is not bound all end in the same status. The `FailedScheduling` message names which filter rejected the nodes, so read the message before you change the template. A message that mentions `node(s) didn't match Pod's node affinity/selector` points to a selector or affinity, a message with `Insufficient cpu` points to requests, and a message with `untolerated taint` points to a taint.

After you fix the right field, the scheduler tries the pod again on its own. No restart of the scheduler and no deletion of the pod is needed.

Check the result with the same steps that found the fault: the pod list, the events of the new pod and a request from the client pod. All three must agree before the repair counts as finished.

## Common pitfalls

> [!WARNING]
> Keep the selected module context and inspect the observed outcome. Resource acceptance does not establish readiness or a successful request. Reset this isolated environment if earlier experiments changed the required starting state.
