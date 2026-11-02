---
draft: true
exam_objectives:
- Debugging in Kubernetes
---
# Restore A Missing ConfigMap Dependency

The `starfleet` application needs this task completed in its isolated lab environment.

## Objective

Diagnose a blocked container and restore its required configuration without changing the Deployment.

## Starting state

The `probe` Deployment requests `GREETING` from a missing ConfigMap. A ConfigMap stores non-secret configuration as named keys. The kubelet cannot start the application container until the required key exists. The Service and client are already present.

Use this lab's private kubeconfig. A kubeconfig contains the cluster address and credentials used by kubectl, the Kubernetes command-line tool. The lab has a separate kind cluster from the module playground.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-028-lab-050-02-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-028-lab-050-02-01" || exit 1
```

Keep this connection selected for every command below.

## Required result

Create ConfigMap `probe-settings` in `starfleet` with key `greeting` and value `welcome`. Keep the existing Deployment image, command, replica count and required `GREETING` reference. Both replicas must become ready and available. A request from `shuttle` to the `probe` Service on port 80 must contain `greeting=welcome`. Do not make the reference optional or replace it with a literal environment value.

## Verify the result

Inspect the required fields and observe the actual result. The grader checks both the resource contract and the running behavior. Wait for controller convergence before submitting.
