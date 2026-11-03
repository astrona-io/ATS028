# Solution: Diagnose And Roll Back A Stuck Rollout

## Step 1. Watch the rollout

```sh
kubectl -n starfleet rollout status deployment/beacon --timeout=20s
```

The command prints `Waiting for deployment "beacon" rollout to finish: 1 out of 2 new replicas have been updated...` and then times out. The Deployment has created a new ReplicaSet, but its pod does not become ready. The old pods keep running, because the default `maxUnavailable` of 25 percent of 2 rounds down to 0.

## Step 2. Find the failing pod and the reason

```sh
kubectl -n starfleet get pods -l app=beacon
kubectl -n starfleet get pods -l app=beacon -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.containerStatuses[0].state.waiting.reason}{"\n"}{end}'
kubectl -n starfleet events --for deployment/beacon
```

One pod shows `ErrImagePull` or `ImagePullBackOff`. `ErrImagePull` is the first failed pull; `ImagePullBackOff` is the wait before the next try. Either value is accepted.

## Step 3. Read the failed image

```sh
kubectl -n starfleet get deployment beacon -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
kubectl -n starfleet rollout history deployment/beacon --revision=2
```

The image is `docker.io/library/python:3.13-alpine-missing`. No such tag exists in the registry.

## Step 4. Record the evidence

```sh
kubectl -n starfleet create configmap rollout-report \
  --from-literal=failed-image=docker.io/library/python:3.13-alpine-missing \
  --from-literal=reason=ImagePullBackOff
```

Use the reason that you saw in step 2.

## Step 5. Roll back and document

```sh
kubectl -n starfleet rollout undo deployment/beacon
kubectl -n starfleet rollout status deployment/beacon --timeout=180s
kubectl -n starfleet annotate deployment/beacon kubernetes.io/change-cause="rollback: the tag python:3.13-alpine-missing does not exist" --overwrite
```

`rollout undo` scales the old ReplicaSet back up and the failed ReplicaSet to 0, so both stay in the history.

## Step 6. Submit

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-030/module-03/labs/lab-01
```
