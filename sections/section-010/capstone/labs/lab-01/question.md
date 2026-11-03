# Task: Migrate An Old Release To The Supported APIs

The namespace `outpost` holds the Service `relay` (it has no pods yet), the client pod `drifter` and the ConfigMap `legacy-bundle`. The ConfigMap stores four manifests from an older Kubernetes release as text under the keys `deployment.yaml`, `cronjob.yaml`, `pdb.yaml` and `hpa.yaml`. The cluster runs Kubernetes v1.35, and none of the four files can be applied as they are. Read a file with, for example, `kubectl -n outpost get configmap legacy-bundle -o jsonpath='{.data.deployment\.yaml}'`.

Do not edit or delete `legacy-bundle` or the ConfigMap `probe-code`.

## Requirements

1. Apply the Deployment `relay` from `deployment.yaml` in the version that the cluster serves. It must have an explicit selector that matches the pod template labels, and it must keep its replicas, image, command, readiness probe and volume.
2. Apply the CronJob `beacon-sweep` from `cronjob.yaml` in the version that the cluster serves. It keeps its schedule, concurrency policy, history limit, restart policy and container.
3. Apply the PodDisruptionBudget `relay-budget` from `pdb.yaml` in the version that the cluster serves. It keeps `maxUnavailable: 1` and its selector.
4. Apply the HorizontalPodAutoscaler `relay-scaler` from `hpa.yaml` in the version that the cluster serves. It keeps its target, replica limits and CPU utilization target.
5. Create the ConfigMap `api-audit` in `outpost` with the keys `deployment`, `cronjob`, `pdb` and `hpa`. Each value is the `group/version` that the API server serves for that kind, for example `apps/v1`. Find each value with the discovery commands. Do not copy it from the legacy files.
6. Wait until the Deployment has 2 ready replicas. The Service `relay` must answer a request from the `drifter` pod.

## How to check your work

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-010/capstone/labs/lab-01
```

Each check prints PASS or a FAIL line that names the difference. Fix it and submit again.
