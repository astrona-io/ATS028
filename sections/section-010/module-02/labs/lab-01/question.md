---
draft: true
exam_objectives:
- Understand API deprecations
---
# Migrate Role, RoleBinding And PriorityClass Definitions

Solve this question on: `terminal`

The `starfleet` team keeps old manifests for the `scout-reader` service account in a repository that was written for an older Kubernetes release. After a cluster upgrade, none of them can be applied. The cluster is Kubernetes v1.35.0 and `kubectl` already points at it as the cluster administrator.

The ConfigMap `legacy-manifests` in the namespace `starfleet` holds the old files as text under the keys `role.yaml`, `rolebinding.yaml` and `priorityclass.yaml`. Read them with `kubectl -n starfleet get configmap legacy-manifests -o jsonpath='{.data.role\.yaml}'`. Do not change this ConfigMap, the `probe` Deployment or the `probe` Service.

1. Apply the Role and the RoleBinding from the old files in the version that the cluster serves. The Role must keep its names and its rules. The RoleBinding must keep binding the service account `scout-reader` to the Role `scout-reader`. The service account must be able to `get` and `list` pods and pod logs in `starfleet`, and nothing else.

2. Apply the PriorityClass from the old file in the version that the cluster serves. It must keep the name `fleet-critical`, the value `900000` and must not be the global default.

3. Record what the cluster serves. Create the ConfigMap `api-findings` in `starfleet` with three keys. The key `role` holds the `group/version` that the API server serves for Roles. The key `priorityclass` holds it for PriorityClasses. The key `ingress` holds it for Ingresses. Find each value with the discovery commands. Do not copy it from an old file.

The `probe` application must keep answering through its Service while you work. The grader checks the live objects, not the files you wrote.
