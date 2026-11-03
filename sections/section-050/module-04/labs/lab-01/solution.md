# Solution: Diagnose And Repair Five Failing Workloads

## Step 1. Read the status of every pod

```sh
kubectl -n starfleet get pods
```

`ensign` shows `ErrImagePull` or `ImagePullBackOff`, `cadet` shows `CreateContainerConfigError`, `captain` shows `Pending`, and `engine` restarts and shows `OOMKilled`, `Error` or `CrashLoopBackOff`. `bridge` is `Running`.

## Step 2. Confirm each cause

```sh
kubectl -n starfleet describe pod -l app=ensign
kubectl -n starfleet describe pod -l app=cadet
kubectl -n starfleet describe pod -l app=captain
kubectl -n starfleet get pod -l app=engine -o jsonpath='{.items[0].status.containerStatuses[0].lastState.terminated.reason}{"\n"}'
kubectl -n starfleet get endpoints bridge
kubectl -n starfleet get service bridge -o jsonpath='{.spec.selector}{"\n"}'
```

The events of `ensign` report a failed image pull for the tag `1.37.99`. The events of `cadet` say that the ConfigMap `cadet-settings` was not found. The `PodScheduled` condition of `captain` has the reason `Unschedulable` and the event says `Insufficient cpu`. The previous state of `engine` has the reason `OOMKilled`. The endpoints of `bridge` are empty, because its selector is `app=bridge-app` and the pod label is `app=bridge`.

## Step 3. Record the causes

Record them before you fix anything, because the evidence disappears with the old pods:

```sh
kubectl -n starfleet create configmap triage-report \
  --from-literal=ensign=ImagePullBackOff \
  --from-literal=cadet=CreateContainerConfigError \
  --from-literal=captain=Unschedulable \
  --from-literal=engine=OOMKilled \
  --from-literal=bridge=app=bridge
```

## Step 4. Repair each fault

```sh
kubectl -n starfleet set image deployment/ensign main=docker.io/library/busybox:1.37.0
kubectl -n starfleet create configmap cadet-settings --from-literal=mode=patrol
kubectl -n starfleet set resources deployment/captain --requests=cpu=100m
kubectl -n starfleet set resources deployment/engine --limits=memory=256Mi
kubectl -n starfleet patch service bridge --type=merge -p '{"spec":{"selector":{"app":"bridge"}}}'
```

Each command changes one object. The pod of `cadet` needs no replacement, because the kubelet retries the container creation and finds the ConfigMap.

## Step 5. Verify

```sh
kubectl -n starfleet get pods
kubectl -n starfleet exec shuttle -- wget -qO- -T 3 http://bridge
```

All pods are `Running`, and the request returns `bridge-ok`.

## Step 6. Submit

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-050/module-04/labs/lab-01
```

The reference script `solution/apply.sh` does steps 3 and 4 in one run.
