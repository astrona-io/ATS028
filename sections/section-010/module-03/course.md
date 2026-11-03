---
draft: true
exam_objectives:
- Understand API deprecations
---
# Migrating Ingress, CronJob, HorizontalPodAutoscaler And PodDisruptionBudget Definitions

Four common application resources lost old API versions in the releases v1.22, v1.25 and v1.26. For two of them a new `apiVersion` is enough. For the other two the fields change, and a definition that only gets a new version string either fails or behaves differently. This module migrates each one and checks the behavior that must stay the same.

## Learning objectives

- Migrate an Ingress from `extensions/v1beta1` to `networking.k8s.io/v1`, including the backend fields, `pathType` and `ingressClassName`.
- Migrate a CronJob from `batch/v1beta1` to `batch/v1` and test it without waiting for its schedule.
- Migrate a HorizontalPodAutoscaler (HPA) from `autoscaling/v2beta1` to `autoscaling/v2` and write its target in the new form.
- Migrate a PodDisruptionBudget (PDB) from `policy/v1beta1` to `policy/v1` and avoid the change in the meaning of an empty selector.
- Name the replacement for PodSecurityPolicy and preview its effect without changing a namespace.

## Before you start

Use a shell on your own machine with the module playground running. You need kubectl, the Kubernetes command-line tool, and the Astrona command-line tool. The playground is a kind cluster that runs Kubernetes v1.35.0, with the metrics-server add-on installed. The metrics-server collects CPU and memory use of Pods, and the HPA reads these values.

The `starfleet` namespace holds the `probe` Deployment, its Service and a ConfigMap named `legacy-manifests`. The ConfigMap stores four old manifests as text. The API server cannot store the removed versions, so the exercises extract each manifest from the ConfigMap, change it and apply the supported version.

## Reading order

1. Migrating Ingress And CronJob Definitions
2. Migrating HorizontalPodAutoscaler And PodDisruptionBudget Definitions
3. Summary

Keep the playground open while you read. A graded lab follows the second reading.

<!-- astrona:playground -->
