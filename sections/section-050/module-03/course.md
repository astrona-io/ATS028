---
draft: true
exam_objectives:
- Debugging in Kubernetes
---
# Debugging Running Pods With exec, port-forward And debug

Reading status and events tells you what Kubernetes did with a pod. It does not tell you what the application process sees from the inside: its environment variables, its files, the ports it listens on and whether it answers a request. `kubectl` has four commands for that inside view: `exec` runs a command in a container, `port-forward` opens a tunnel from your machine to a pod port, `debug` adds a temporary container to a running pod, and `cp` copies files. This module explains which cluster component carries each command and what each one can and cannot reach.

## Learning objectives

After this module you can:

- Run one-off commands in a container with `kubectl exec`, choose the container with `-c`, and read the environment and listening ports from inside.
- Open a tunnel with `kubectl port-forward` to a pod, a Deployment or a Service, and state which components carry the traffic.
- Attach an ephemeral container to a running pod with `kubectl debug`, and explain why it can see the processes of another container.
- Copy files with `kubectl cp` and name what it needs inside the container.
- Compare the port a process listens on with the `containerPort` and `targetPort` fields, and correct the Service.

## Before you start

You need to know what a pod, a container and a Service are. The playground is a single-node kind cluster. The `starfleet` namespace holds the Deployment `probe` with a Service `probe`, a pod `scout` with a Service `scout`, and a client pod `shuttle`. The `outpost` namespace holds a client pod `drifter`. The pod `scout` has a configuration mistake that you find with the commands in this module.

## Reading order

1. Running Commands And Tunnels With exec And port-forward
2. Ephemeral Containers And File Copy
3. Summary

Launch your playground now and keep it open while you read:

<!-- astrona:playground -->
