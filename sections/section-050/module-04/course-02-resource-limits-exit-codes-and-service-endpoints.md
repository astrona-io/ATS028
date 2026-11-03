---
draft: true
exam_objectives:
- Debugging in Kubernetes
---
# Resource Limits, Exit Codes And Service Endpoints

Some faults appear only after the process has started. The kernel can end a process that uses more memory than its container limit, and a Service can run without any pod behind it. These faults do not show up as waiting reasons. They show up as a restart count, an exit code and an empty list of endpoints. This part reads that evidence for the workloads `engine` and `bridge`, and then states the rule for choosing the correction.

## Terminated containers and exit codes

The container in the pod of `engine` allocates about 150 MiB of memory at start, and its memory limit is 64 MiB. List the pods:

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet get pods -l app=engine
```

The `STATUS` column alternates between `OOMKilled`, `Error` or `CrashLoopBackOff`, and the `RESTARTS` column grows. `CrashLoopBackOff` is not a cause. It is the kubelet waiting before it restarts a container that keeps stopping, and the wait doubles up to five minutes. The cause is in the state of the container before the current attempt:

```sh
kubectl -n starfleet get pod -l app=engine -o jsonpath='{.items[0].status.containerStatuses[0].lastState.terminated}{"\n"}'
```

The JSON object has the fields `reason`, `exitCode`, `startedAt` and `finishedAt`. The reason is `OOMKilled` and the exit code is `137`. The `describe` output shows the same record as `Last State: Terminated`, with `Reason: OOMKilled` and `Exit Code: 137`.

The exit code is `128` plus the number of the signal that ended the process. The code `137` is `128 + 9`, and signal 9 is `SIGKILL`. When a cgroup (a Linux kernel group that limits resources) runs out of memory, the kernel kills a process in it with `SIGKILL`, and the container runtime reports `OOMKilled`. Other codes tell different stories: `1` is a general application error, `126` and `127` mean the command could not run or was not found, `143` is `128 + 15` for a normal stop with `SIGTERM`, and `0` is a clean exit.

## Requests and limits do different work

Requests and limits are both in the `resources` field, but different components use them.

- The scheduler uses `requests` before the pod starts. It places the pod on a node that has that much allocatable capacity left.
- The kubelet and the container runtime enforce `limits` while the process runs. A container that goes over its memory limit is killed. A container that goes over its CPU limit is slowed down and is not killed.

A pod that has a small request and a large real need can be scheduled and then be killed under load. A pod with a request larger than any node can offer is never scheduled. The first fault is seen as `OOMKilled` after the start, the second as `Pending` without a start.

```sh
kubectl -n starfleet get deployment engine -o jsonpath='{.spec.template.spec.containers[0].resources}{"\n"}'
```

The correction for `engine` is to raise the memory limit above what the process needs. For this process, 256 MiB is enough:

```sh
kubectl -n starfleet set resources deployment/engine --limits=memory=256Mi
```

The Deployment creates a new pod with the new limit, and the restart count of the new pod stays at zero. Raising a limit also depends on the node: the limit does not make memory available. A node that has no free memory evicts or kills pods even if their limits are high. Check real usage with `kubectl top pod` when the metrics API is installed.

## Service with no endpoints

The pod of `bridge` is `Running` and ready, but a request through its Service fails. From the client pod `shuttle`:

```sh
kubectl -n starfleet exec shuttle -- wget -qO- -T 3 http://bridge
```

The request fails after the timeout or with a connection error. The pod works, so check the step between the client and the pod. A Service sends traffic to the pods that its `selector` matches, among those that are ready. The controller keeps the list in EndpointSlice objects:

```sh
kubectl -n starfleet get endpoints bridge
kubectl -n starfleet get service bridge -o jsonpath='{.spec.selector}{"\n"}'
kubectl -n starfleet get pods -l app=bridge --show-labels
```

The endpoints list for `bridge` is empty. The selector of the Service is `app=bridge-app`, but the pod has the label `app=bridge`. The labels do not match, so no pod is selected. A Service does not report an error for this. It exists and has a cluster IP, but it has no backends.

Correct the object that is wrong. The pod labels match the Deployment selector, and other things may depend on them, so you change the Service:

```sh
kubectl -n starfleet patch service bridge --type=merge -p '{"spec":{"selector":{"app":"bridge"}}}'
kubectl -n starfleet get endpoints bridge
kubectl -n starfleet exec shuttle -- wget -qO- -T 3 http://bridge
```

The endpoints now list the pod IP with port 8080, and the request returns `bridge-ok`. If the endpoints had been filled but the request still failed, the next checks would be the `targetPort` against the real listening port and the readiness of the pods, because only ready pods are listed.

## Choosing the correction

The five faults in this module have five different corrections, and none of them was a restart. A short table keeps the mapping in one place.

| Evidence | Failed stage | Correction |
| --- | --- | --- |
| `Pending`, `FailedScheduling`, `Insufficient cpu` | Scheduling | Lower the request to what the workload needs |
| `ErrImagePull`, `ImagePullBackOff` | Image pull | Use an image reference that exists |
| `CreateContainerConfigError`, ConfigMap not found | Container creation | Create the ConfigMap with the expected key |
| `OOMKilled`, exit code 137 | Process runtime | Raise the memory limit, or fix the memory use |
| Service with empty endpoints | Traffic | Make the selector match the pod labels |

Work in the order of the stages. When a pod fails at an early stage, ignore the later ones, because they cannot be observed yet. After each correction repeat the original check, for example the request from `shuttle`, to prove that the behavior is back. A correction that only makes the status look green, such as removing a limit entirely, is not a fix.

## Common pitfalls

- Reading `CrashLoopBackOff` as the cause. It is the retry delay, and the cause is in `lastState` and in the previous logs.
- Raising a memory limit far above the node capacity. The pod then starts and the node runs out of memory.
- Assuming that a Service is broken when the pod is `Running`. First compare the selector with the labels and read the endpoints.
- Changing pod labels to match a Service when other objects select on those labels.
- Treating exit code 137 as always `OOMKilled`. A `kubectl delete` that exceeds the grace period also ends with `SIGKILL`; read the `reason` field as well.
