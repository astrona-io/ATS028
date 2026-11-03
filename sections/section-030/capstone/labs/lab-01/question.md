# Task: Inspect A Fleet And Roll Back A Failed Update

The namespace `starfleet` runs three Deployments (`hail`, `dock`, `keel`) and one bare pod whose name starts with `valve-`. Every pod has the labels `tier` and `env`. The update of `dock` was applied a few minutes ago and never finished. A teammate asks for a report, a review mark and a rollback. Use label selectors and output formats; do not read names by eye from a long listing.

## Requirements

1. Create the ConfigMap `fleet-report` in `starfleet` with four keys:
   - `prod-web-pods`: the names of all pods that have the labels `tier=web` and `env=prod`, one name per line, without the `pod/` prefix.
   - `restarting-pod`: the name of the pod that has restarted.
   - `failed-image`: the full image reference that the stuck revision of `dock` tries to run.
   - `reason`: the waiting reason that Kubernetes reports for the failing `dock` pod.
2. Add the label `reviewed=true` to every pod that has the label `env=prod`, and to no other pod.
3. Roll `dock` back so that it runs the previous working image with 2 ready replicas. Keep the failed ReplicaSet in the history; do not delete it.
4. Set the annotation `kubernetes.io/change-cause` on `dock` to a short text that describes the rollback. It must not be one of the texts that the Deployment already carries.
5. Do not change the Deployments `hail` and `keel`.

Collect the evidence for requirement 1 before you roll back, because the failing pod is gone after the rollback.

## How to check your work

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-030/capstone/labs/lab-01
```

Each check prints PASS or a FAIL line that names the difference. Fix it and submit again.
