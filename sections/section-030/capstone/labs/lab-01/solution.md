# Solution: Inspect A Fleet And Roll Back A Failed Update

## Step 1. List the pods with their labels

```sh
kubectl -n starfleet get pods --show-labels
```

The listing shows the pods of the three Deployments, the `valve-` pod, `shuttle`, and the `tier` and `env` labels of each. The `dock` update has pods that are not ready.

## Step 2. Select the production web pods

```sh
kubectl -n starfleet get pods -l tier=web,env=prod -o name | sed 's#^pod/##'
```

A comma between two selectors means both must match. `-o name` prints one `pod/<name>` per line, and `sed` removes the prefix. Note the lines.

## Step 3. Find the pod that restarted

```sh
kubectl -n starfleet get pods --sort-by='.status.containerStatuses[0].restartCount'
```

The pod with the highest `RESTARTS` value is listed last. It is the `valve-` pod. Note its full name.

## Step 4. Collect the evidence for the stuck rollout

```sh
kubectl -n starfleet rollout status deployment/dock --timeout=10s
kubectl -n starfleet get deployment dock -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
kubectl -n starfleet get pods -l app=dock
```

The first command reports that the rollout is waiting. The second prints the image of the stuck revision, which ends in `3.13-alpine3.99`. The status column of the new pod shows `ErrImagePull` or `ImagePullBackOff`; this is the reason.

## Step 5. Create the report

```sh
kubectl -n starfleet create configmap fleet-report \
  --from-literal=prod-web-pods="<names from step 2, separated by newlines>" \
  --from-literal=restarting-pod=<name from step 3> \
  --from-literal=failed-image=<image from step 4> \
  --from-literal=reason=<reason from step 4>
```

A newline inside the quoted value stores several lines in one key.

## Step 6. Mark the production pods

```sh
kubectl -n starfleet label pods -l env=prod reviewed=true
kubectl -n starfleet get pods -l reviewed=true
```

The `hail` and `keel` pods carry the label. The label selector `env=prod` does not match the `dock` pods or the `valve-` pod.

## Step 7. Roll back and document

```sh
kubectl -n starfleet rollout history deployment/dock
kubectl -n starfleet rollout undo deployment/dock
kubectl -n starfleet annotate deployment/dock kubernetes.io/change-cause="rolled back the missing image tag" --overwrite
kubectl -n starfleet rollout status deployment/dock
```

`rollout undo` makes the Deployment use the pod template of the previous revision again. The failed ReplicaSet stays in the history with zero pods.

## Step 8. Submit

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-030/capstone/labs/lab-01
```

`solution/apply.sh` applies the same steps with commands.
