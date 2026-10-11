---
draft: true
exam_objectives:
- Debugging in Kubernetes
---
# Locate Pending Placement And Repair A Node Selector

An intentionally unmatched node selector prevents the new Pod template from being scheduled. You will inspect Pending Pods and scheduler events, then remove only the unsupported selector. This separates placement from image preparation or an application process that has already started.

Use the module playground and its private kubeconfig. The context check below prevents commands from being directed at an unrelated cluster. The helper retries a command for a bounded interval after controller or policy changes; it cannot turn a persistent failure into success. Read the actual errors when the interval expires.

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

## Common pitfalls

> [!WARNING]
> Keep the selected module context and inspect the observed outcome. Resource acceptance does not establish readiness or a successful request. Reset this isolated environment if earlier experiments changed the required starting state.
