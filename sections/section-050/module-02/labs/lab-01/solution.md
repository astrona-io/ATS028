---
draft: true
exam_objectives:
- Debugging in Kubernetes
---
# Restore A Missing ConfigMap Dependency Solution

Use this lab's private kubeconfig. A kubeconfig contains the cluster address and credentials used by kubectl, the Kubernetes command-line tool. The lab has a separate kind cluster from the module playground.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-028-lab-050-02-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-028-lab-050-02-01" || exit 1
```

Keep this connection selected for every command below.

## Diagnose The Starting State

The `probe` Deployment requests `GREETING` from a missing ConfigMap. A ConfigMap stores non-secret configuration as named keys. The kubelet cannot start the application container until the required key exists. The Service and client are already present.

Inspect the relevant objects:

```sh
kubectl -n starfleet get pods -l app=probe
kubectl -n starfleet describe pods -l app=probe
kubectl -n starfleet get deployment probe -o yaml
```

The waiting reason and events identify the missing configuration dependency. Inspect `valueFrom.configMapKeyRef` to find its name and key. Creating that object fixes the dependency. The kubelet retries container creation without requiring a change to the Deployment template.

Save this as `configmap-probe-settings.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: probe-settings
  namespace: starfleet
data:
  greeting: welcome
```

Apply it:

```sh
kubectl apply -f configmap-probe-settings.yaml
```

## Verify The Result

Observe the actual result with these bounded checks. No example transcript is provided as evidence of a completed run.

```sh
kubectl -n starfleet rollout status deployment/probe --timeout=180s
kubectl -n starfleet exec shuttle -- wget -q -T 3 -O- http://probe/
```

Create ConfigMap `probe-settings` in `starfleet` with key `greeting` and value `welcome`. Keep the existing Deployment image, command, replica count and required `GREETING` reference. Both replicas must become ready and available. A request from `shuttle` to the `probe` Service on port 80 must contain `greeting=welcome`. Do not make the reference optional or replace it with a literal environment value.

After recording your result, remove this lab with `astrona destroy ats-028-lab-050-02-01`.

## Common pitfalls

> [!WARNING]
> Verify the lab context before making changes. A matching field alone does not prove the required behavior. Preserve the objects and access limits named in the task.
