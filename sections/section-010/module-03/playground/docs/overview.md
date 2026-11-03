---
draft: true
exam_objectives:
- Understand API deprecations
---
# Resource Migration Playground

This ungraded playground is an isolated kind cluster that runs Kubernetes v1.35.0 with the metrics-server add-on. It has its own kubeconfig, the file that tells kubectl which cluster and credentials to use. Nothing in it is submitted for grading.

The `starfleet` namespace contains the `probe` Deployment with two Pods that request `10m` of CPU, the `probe` Service and the `shuttle` client Pod. The `outpost` namespace contains the `drifter` client Pod. The ConfigMap `legacy-manifests` in `starfleet` holds four manifests as text: an Ingress for `extensions/v1beta1`, a CronJob for `batch/v1beta1`, a HorizontalPodAutoscaler for `autoscaling/v2beta1` and a PodDisruptionBudget for `policy/v1beta1`. The API server cannot store these versions, so the exercises extract them with jsonpath.

Select the private kubeconfig before running commands:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-028-playground-010-03)"
kubectl config current-context
```

The context must be `kind-astro-ats-028-playground-010-03`. If it differs, stop and select the playground again. The first start needs network access to pull images, and the container engine must support the pinned kind node image.

No Ingress controller is installed. An Ingress object is stored and its fields can be read, but no traffic is routed through it. The HorizontalPodAutoscaler needs about a minute after creation before the metrics-server reports CPU use.

To reset, destroy the playground and start it again. The summary page removes it. For manual cleanup:

```sh
astrona destroy ats-028-playground-010-03
```
