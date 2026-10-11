---
draft: true
exam_objectives:
- Understand API deprecations
---
# Discover A Served API And Reject A Removed Definition

API migration requires both a served version and a valid schema for that version. You will compare an intentionally removed Ingress definition with a current definition using server-side dry run. This playground does not install an Ingress controller; accepted Ingress syntax is therefore not evidence of an externally served application.

Use the module playground and its private kubeconfig. The context check below prevents commands from being directed at an unrelated cluster. The helper retries a command for a bounded interval after controller or policy changes; it cannot turn a persistent failure into success. Read the actual errors when the interval expires.

<!-- astrona:playground:renew -->

For a timed catalog session, renew this module before continuing. Skip renewal for an untimed local author run:

```sh
astrona run renew astrona-io/ATS028/section-010/module-01/playground
```

Select the module environment and define a bounded retry helper:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-028-playground-010-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-028-playground-010-01"
kubectl -n starfleet get pods
wait_for_success() {
  for attempt in 1 2 3 4 5 6 7 8 9 10; do
    if "$@"; then return 0; fi
    sleep 1
  done
  return 1
}
```

Discover the served Ingress resource and explain its backend contract.

```sh
kubectl api-resources --api-group=networking.k8s.io
kubectl explain ingress.spec.rules.http.paths --api-version=networking.k8s.io/v1
```

Discovery establishes which API the server exposes. Explanation describes its schema; neither proves that a controller is installed or that traffic reaches a workload.

Save the old definition and ask the server to validate it without persistence. The shell condition expects rejection and reports an error if the removed API is unexpectedly accepted.

Save this as `ingress-removed.yaml`:

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: probe
  namespace: starfleet
spec:
  backend:
    serviceName: probe
    servicePort: 80
```

Apply or use the saved input, then check the result:

```sh
if kubectl apply --dry-run=server -f ingress-removed.yaml; then printf "Removed API unexpectedly accepted\n" >&2; exit 1; fi
```

The failure should concern an unavailable API or incompatible definition. Read the actual error instead of inventing its wording. A client-only parse would not establish the server contract.

Save the complete current definition and use server-side dry run again.

Save this as `ingress-current.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: probe
  namespace: starfleet
spec:
  ingressClassName: traefik
  rules:
  - host: probe.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: probe
            port:
              number: 80
```

Apply or use the saved input, then check the result:

```sh
kubectl apply --dry-run=server -f ingress-current.yaml
```

The current schema names pathType and a structured Service backend. The operation should validate without creating a live Ingress. It intentionally establishes only the API boundary.

Changing apiVersion without migrating fields can leave a definition invalid. Use discovery, schema and server validation together. If you need to prove external routing, a compatible controller and a request path are additional requirements rather than consequences of successful validation.

## Common pitfalls

> [!WARNING]
> Keep the selected module context and inspect the observed outcome. Resource acceptance does not establish readiness or a successful request. Reset this isolated environment if earlier experiments changed the required starting state.
