---
draft: true
exam_objectives:
- Debugging in Kubernetes
---
# Ephemeral Containers And File Copy

Some containers cannot be inspected with `exec`, because their image contains only the application binary. A shell, a network tool or a process viewer is missing, and rebuilding the image for a one-time investigation is slow and changes what you wanted to observe. An ephemeral container solves this: it is a container that you add to a running pod, with an image that carries the tools you need. This part explains what an ephemeral container shares with the pod, how `kubectl debug` creates one and how `kubectl cp` moves files.

## What an ephemeral container is

A pod specification has `containers`, `initContainers` and `ephemeralContainers`. The first two lists are fixed when the pod is created. The `ephemeralContainers` list is different: the API server accepts additions to it on a running pod through a dedicated subresource, `pods/ephemeralcontainers`. You cannot change or remove an entry afterwards, and an ephemeral container is never restarted. It has no ports, no probes and no resource guarantees. It exists only to look around.

All containers of a pod share one network namespace. An ephemeral container therefore sees the same IP address and the same sockets as the application container. A request to `127.0.0.1:9090` from the ephemeral container reaches the application. Processes and filesystems are separate unless you ask for more.

## Adding one with kubectl debug

Open the playground and attach a container that runs a long sleep, so that it stays available:

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet debug scout -c inspector --image=docker.io/library/busybox:1.37.0 --target=app -- sleep 3600
```

The flags have these meanings:

- `scout` is the pod to add the container to.
- `-c inspector` names the ephemeral container. Without it `kubectl` generates a name such as `debugger-xxxxx`.
- `--image` is the image with the tools.
- `--target=app` asks the container runtime to share the process namespace of the container `app`. The ephemeral container then sees the processes of the application.
- Everything after `--` is the command to run.

`kubectl` sends an update to the `ephemeralcontainers` subresource, and the kubelet starts the container. Check that it is there:

```sh
kubectl -n starfleet get pod scout -o jsonpath='{.spec.ephemeralContainers[*].name}{"\n"}'
```

The command prints `inspector`. The container status is in `status.ephemeralContainerStatuses`, and `kubectl describe pod scout` has an `Ephemeral Containers` section.

The pod keeps running and keeps its name, its IP address and its UID. The application container is not restarted.

## Using the ephemeral container

Run a command in the new container with `exec` and `-c`:

```sh
kubectl -n starfleet exec scout -c inspector -- ps
kubectl -n starfleet exec scout -c inspector -- wget -qO- http://127.0.0.1:9090
```

`ps` lists the process `python -m http.server 9090` of the application container, because of `--target`. The second command reaches the web server through the shared network namespace. The tools come from the BusyBox image, and the application image is unchanged.

With `-i -t` and no command, `kubectl debug` opens a shell directly:

```sh
kubectl -n starfleet debug -it scout --image=docker.io/library/busybox:1.37.0 --target=app
```

Leaving the shell ends the process, but the ephemeral container entry stays in the pod specification until the pod is deleted. Each call with a new name adds another entry.

## Debugging a copy instead

Sometimes you need to change the pod to debug it, for example to replace the command or the image. Pods are mostly immutable, so `kubectl debug` can create a copy:

```sh
kubectl -n starfleet debug scout --copy-to=scout-debug --container=app --image=docker.io/library/python:3.13-alpine -- sleep 3600
```

The copy is a separate pod named `scout-debug`. Its container `app` has the new image and the new command, and the labels are kept unless you change them. A copy that keeps the label `app=scout` would also receive traffic from the Service. Delete the copy when you finish with `kubectl delete pod scout-debug`. For problems on a node, `kubectl debug node/NAME -it --image=...` starts a pod on that node with the node filesystem mounted at `/host`.

## Copying files with kubectl cp

`kubectl cp` copies files between your machine and a container:

```sh
kubectl -n starfleet cp scout:/etc/os-release ./scout-os-release -c app
kubectl -n starfleet cp ./scout-os-release scout:/tmp/os-release-copy -c app
```

The first command copies a file out of the pod, the second copies a file in. `kubectl cp` has no server side. It runs `tar` inside the container through `exec` and reads or writes the archive on the stream. That is why the container needs the `tar` executable, and why `kubectl cp` fails on minimal images with an error that mentions `tar`. The path of a pod can be prefixed with a namespace as in `starfleet/scout:/path`, and the command copies a single file or a whole directory.

## Fixing what the evidence shows

The investigation so far found that the process listens on port 9090 while the Service sends traffic to port 8080. You correct the Service, which is the object that is wrong. The pod is correct and stays as it is:

```sh
kubectl -n starfleet patch service scout --type=merge -p '{"spec":{"ports":[{"name":"http","port":80,"targetPort":9090}]}}'
kubectl -n starfleet exec shuttle -- wget -qO- -T 3 http://scout
```

The Service now has `targetPort: 9090`, and the request from the client pod `shuttle` returns the directory listing. A merge patch replaces the whole `ports` list, so the patch repeats every field that must survive. Changing the `containerPort` in the pod would not fix anything: the field is documentation, and a pod cannot be edited to change it.

You now know how to take evidence from a running pod and how to correct a Service from it. The next step in a real investigation is usually a pod that never runs at all, where you must read status instead of looking inside.

## Common pitfalls

- Adding an ephemeral container without `--target` and then wondering why `ps` shows no application process.
- Expecting to delete an ephemeral container. The list is append-only, and only deleting the pod removes it.
- Leaving a debug copy with the application label in place, so that the Service sends real traffic to it.
- Using `kubectl cp` on an image without `tar` and treating the error as a permission problem.
- Using `kubectl debug` on a cluster where the ephemeral containers feature is unavailable. It is enabled by default in Kubernetes 1.25 and later.
