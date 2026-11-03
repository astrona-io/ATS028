---
draft: true
exam_objectives:
- Understand API deprecations
---
# Deprecation Detection Playground

This ungraded playground is an isolated kind cluster that runs Kubernetes v1.35.0. It has its own kubeconfig, the file that tells kubectl which cluster and credentials to use. Nothing in it is submitted for grading.

The `starfleet` namespace contains the `probe` Deployment with two Pods, the `probe` Service and the `shuttle` client Pod. The `outpost` namespace contains the `drifter` client Pod. The `shuttle-reader` service account and the ConfigMap `legacy-manifests` are also in `starfleet`. The ConfigMap holds four manifests as text: a Role and a RoleBinding for `rbac.authorization.k8s.io/v1beta1`, a PriorityClass for `scheduling.k8s.io/v1beta1` and an Ingress for `extensions/v1beta1`. The API server cannot store these versions, so the cluster keeps them as text and the exercises extract them with jsonpath.

Select the private kubeconfig before running commands:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-028-playground-010-02)"
kubectl config current-context
```

The context must be `kind-astro-ats-028-playground-010-02`. If it differs, stop and select the playground again. The first start needs network access to pull images, and the container engine must support the pinned kind node image.

Read the actual output of each command. A `Warning:` line, a `no matches for kind` error and a permission error mean three different things, and the first failed dependency in the output is the one to fix. If the start fails, Astrona prints the location of the run logs.

To reset, destroy the playground and start it again. The summary page removes it. For manual cleanup:

```sh
astrona destroy ats-028-playground-010-02
```
