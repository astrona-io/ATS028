# Task: Diagnose And Roll Back A Stuck Rollout

In the namespace `starfleet`, the Deployment `beacon` (2 replicas) was updated a few minutes ago, and the update never finished. The Deployment `probe` is healthy and must not be changed. Find out why the rollout is stuck, record the evidence, restore service and document the change.

## Requirements

1. Create a ConfigMap named `rollout-report` in `starfleet` with two keys:
   - `failed-image`: the full image reference that the stuck revision tries to run.
   - `reason`: the waiting reason that Kubernetes reports for the failing pod, for example the value shown in the `STATUS` column or in the container state.
2. Roll `beacon` back so that it runs the previous working image with 2 ready replicas. Keep the failed ReplicaSet in the history; do not delete it.
3. Set the annotation `kubernetes.io/change-cause` on the `beacon` Deployment to a short text that describes the rollback. It must not be one of the texts that the Deployment already carries.
4. Do not change the `probe` Deployment.

Collect the evidence before you roll back: after the rollback the failing pod is gone.

## How to check your work

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-030/module-03/labs/lab-01
```
