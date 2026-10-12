---
draft: true
exam_objectives:
- Use built-in CLI tools to monitor Kubernetes applications
---
# Combine Resource Status, Events And Live Metrics

This playground enables metrics-server in addition to ordinary API inspection. You will compare desired resources, events and live resource measurements. A measurement snapshot describes a recent observed population and is not a complete history or a guarantee that configured requests equal usage.

Use the module playground and its private kubeconfig. The context check below prevents commands from being directed at an unrelated cluster. The helper retries a command for a bounded interval after controller or policy changes; it cannot turn a persistent failure into success. Read the actual errors when the interval expires.

Object inspection, event inspection and usage metrics come from different observation paths. Read desired replicas against available replicas, then use Pod state to explain any difference. Metrics Server adds recent usage and may need time to collect its first samples.

Requests and limits are declared settings, while `top` reports measured consumption. An unavailable metrics response does not prove the application is down. Keep the selected context and namespace fixed so all observations describe the same workload.

<!-- astrona:playground:renew -->

For a timed catalog session, renew this module before continuing. Skip renewal for an untimed local author run:

```sh
astrona run renew astrona-io/ATS028/section-030/module-01/playground
```

Select the module environment and define a bounded retry helper:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-028-playground-030-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-028-playground-030-01"
kubectl -n starfleet get pods
wait_for_success() {
  for attempt in 1 2 3 4 5 6 7 8 9 10; do
    if "$@"; then return 0; fi
    sleep 1
  done
  return 1
}
```

Inspect workload conditions and recent namespace events before examining measurements.

```sh
kubectl -n starfleet get deployments,pods -o wide
kubectl -n starfleet describe deployment probe
kubectl -n starfleet get events --sort-by=.metadata.creationTimestamp
```

These commands report specifications, status and event evidence. They do not return the same information as a resource-usage sample.

Check the metrics API and obtain Pod and node measurements. A new cluster may need an initial collection interval before data appears.

```sh
kubectl wait --for=condition=Available apiservice/v1beta1.metrics.k8s.io --timeout=120s
wait_for_success kubectl -n starfleet top pods
wait_for_success kubectl top nodes
```

If samples are not yet available, wait for collection and inspect metrics-server evidence. Do not invent CPU or memory values or conclude that missing metrics mean the application used no resources.

Compare the probe resource requests and limits with the returned measurements.

```sh
kubectl -n starfleet get deployment probe -o jsonpath='{.spec.template.spec.containers[0].resources}{"\n"}'
kubectl -n starfleet logs deployment/probe --tail=10
```

Requests influence scheduling and limits constrain selected runtime behavior. Recent usage can differ from both. Logs add application evidence but are not a replacement for the metrics model.

Choose the evidence that answers your question and state its time scope. A healthy status can coexist with high resource usage, and a low usage snapshot does not prove a future burst will fit the configured limit. Metrics-server is a practice dependency explicitly included here.

## Common pitfalls

> [!WARNING]
> Keep the selected module context and inspect the observed outcome. Resource acceptance does not establish readiness or a successful request. Reset this isolated environment if earlier experiments changed the required starting state.
