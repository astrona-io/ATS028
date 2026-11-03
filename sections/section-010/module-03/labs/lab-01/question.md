---
draft: true
exam_objectives:
- Understand API deprecations
---
# Task: Migrate Ingress, CronJob, HorizontalPodAutoscaler And PodDisruptionBudget

After a cluster upgrade, four definitions of the application in the namespace `starfleet` no longer apply, because they use API versions that the cluster does not serve. The old definitions are stored in the ConfigMap `legacy-manifests` in `starfleet`, under the keys `ingress.yaml`, `cronjob.yaml`, `hpa.yaml` and `pdb.yaml`. Read them, write the definitions in a supported API version, and apply them. The Deployment `probe`, its Service and the pod `shuttle` run and must not be changed.

## Requirements

1. Create the Ingress `probe-edge` with the group version `networking.k8s.io/v1`. Keep the host `edge.starfleet.example` and the path `/status`. Select the controller with the field `spec.ingressClassName` (value `nginx`), not with an annotation. Give the path an explicit `pathType`, and point the backend at the Service `probe`, port 80.
2. Create the CronJob `shuttle-sweep` with the group version `batch/v1`. Keep its schedule, `concurrencyPolicy`, `successfulJobsHistoryLimit`, `restartPolicy` and container exactly as in the legacy file.
3. Create the HorizontalPodAutoscaler `probe-scaler` with the group version `autoscaling/v2`. It targets the Deployment `probe`, scales between 2 and 5 replicas, and keeps the CPU target of 55 percent as a `Utilization` target.
4. Create the PodDisruptionBudget `probe-budget` with the group version `policy/v1`. Keep `minAvailable: 1` and select the pods with the label `app: probe`.
5. Do not change the Deployment `probe` or its Service.

## How to check your work

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-010/module-03/labs/lab-01
```

Each check prints PASS or a FAIL line that names the difference. Fix it and submit again.
