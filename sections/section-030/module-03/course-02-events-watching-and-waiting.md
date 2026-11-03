---
draft: true
exam_objectives:
- Use built-in CLI tools to monitor Kubernetes applications
---
# Events, Watching And Waiting

Object status tells you the current state. It does not tell you what the cluster did to reach it. Events fill that gap. An event is a small API object that a controller, the scheduler or the kubelet creates when it takes an action or meets a problem: a pod was scheduled, an image was pulled, a probe failed, a container was killed. Events are the first place to look when a pod does not behave as the specification says.

## What an event contains

Every event has a `type` (`Normal` or `Warning`), a `reason` (a short CamelCase word such as `Scheduled`, `Pulled`, `Failed`, `BackOff`, `Unhealthy`), a `message`, the `involvedObject` (the object it is about), a `count` or series information and a timestamp. The reporting component is in `reportingComponent` or `source`: `default-scheduler`, `kubelet`, `deployment-controller` and so on.

Events are stored in etcd like any object, but with a time to live. The API server deletes an event about one hour after its last occurrence by default. After that hour, `kubectl events` shows nothing about an old failure, even if the failure is still going on. Status fields and container logs do not expire in this way, so use them when the event is gone.

## Reading events

Open the playground and read the events of the namespace:

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet get events
kubectl -n starfleet events
```

The two commands differ. `kubectl get events` returns the list in the order of the API server, which is not sorted by time. `kubectl events` is the dedicated command: it sorts by time and prints `LAST SEEN`, `TYPE`, `REASON`, `OBJECT` and `MESSAGE`. Prefer it. When you must use `get`, add the sort yourself:

```sh
kubectl -n starfleet get events --sort-by=.lastTimestamp
```

## Filtering events

```sh
kubectl -n starfleet events --types=Warning
kubectl -n starfleet events --for deployment/beacon
kubectl -n starfleet events --for pod/shuttle
kubectl events -A --types=Warning
```

`--types` accepts `Normal` and `Warning`. `--for` takes `TYPE/NAME` and prints only events whose involved object is that one object. Events of the pods that a Deployment owns are about the pods, not about the Deployment, so use `kubectl describe` or select the pod names. With `get events` use a field selector:

```sh
kubectl -n starfleet get events --field-selector involvedObject.kind=Pod,type=Warning
kubectl -n starfleet get events --field-selector reason=BackOff
```

## Events in describe

`kubectl describe pod NAME` ends with an `Events:` section for that pod. Read it from the top: the order is the order of the pod lifecycle. A healthy start shows `Scheduled`, `Pulling`, `Pulled`, `Created` and `Started`. Each missing or failing step names the stage that failed:

| Last good reason | Next reason seen | Stage that failed |
| --- | --- | --- |
| none | `FailedScheduling` | The scheduler found no node |
| `Scheduled` | `Failed`, `ErrImagePull`, `BackOff` | Image pull |
| `Started` | `Unhealthy` | A probe failed |
| `Started` | `Killing` | The kubelet stopped a container |

Break an update on purpose and read the evidence:

```sh
kubectl -n starfleet set image deployment/beacon web=docker.io/library/python:3.13-alpine-missing
kubectl -n starfleet get pods -l app=beacon
kubectl -n starfleet events --types=Warning
```

The new pod is in `ErrImagePull`, later `ImagePullBackOff`, and the warnings name the image and the registry error. Undo it with `kubectl -n starfleet rollout undo deployment/beacon`.

## Watching live changes

Add `-w` (`--watch`) to `get` to keep the connection open and print one line for every change:

```sh
kubectl -n starfleet get pods -w
kubectl -n starfleet get pods -w --output-watch-events
kubectl -n starfleet get deployment beacon -w
kubectl -n starfleet events --watch
```

A watch is a long-lived request to the API server, which streams `ADDED`, `MODIFIED` and `DELETED` notifications. The first lines are the current state; later lines are changes. `--output-watch-events` adds the event type to each line. Stop with Ctrl-C. A watch can end on its own when the connection times out; start it again.

Run a watch in a second terminal while you scale in the first:

```sh
kubectl -n starfleet scale deployment/probe --replicas=3
kubectl -n starfleet scale deployment/probe --replicas=2
```

You see a pod move through `Pending`, `ContainerCreating`, `Running` with `READY 0/1` and then `1/1`, then `Terminating` on scale down.

## Waiting for a condition

A script must not sleep and hope. `kubectl wait` blocks until a condition is true or a timeout passes, and exits non-zero on timeout:

```sh
kubectl -n starfleet wait --for=condition=Ready pod/shuttle --timeout=60s
kubectl -n starfleet wait --for=condition=Available deployment/probe --timeout=60s
kubectl -n starfleet wait --for=delete pod/doesnotexist --timeout=5s
kubectl -n starfleet wait --for=jsonpath='{.status.phase}'=Running pod/shuttle
```

`--for=condition=NAME` reads the entries of `status.conditions`. `--for=delete` waits until the object is gone. `--for=jsonpath` compares any field with a value.

## Common pitfalls

> [!WARNING]
> - **Looking for an old failure in events.** Events expire after about an hour.
> - **Reading `get events` as ordered.** Sort it or use `kubectl events`.
> - **Using `--for deployment/NAME` and expecting pod events.** Those events are about the pods.
> - **Assuming a watch never ends.** The server closes idle watches.
> - **Sleeping in a script.** Use `wait` or `rollout status`.
