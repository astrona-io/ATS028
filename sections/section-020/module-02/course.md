---
draft: true
exam_objectives:
- Implement probes and health checks
---
# Probe Handlers: HTTP, TCP, Exec And gRPC

A probe is a check that the kubelet, the Kubernetes agent on each node, runs against a container. Every probe has a handler: the mechanism the kubelet uses to ask the container whether it is healthy. Kubernetes has four handlers: an HTTP request, a TCP connection, a command run inside the container, and a gRPC health request. Choosing a handler that does not match what the application really offers is one of the most common reasons a pod never becomes ready or restarts without a visible cause.

This module explains what each handler sends, which component sends it, what counts as success and what each wrong setting looks like in the pod events. You will build probes for a small web application in the playground, break them on purpose and read the evidence.

## Learning objectives

After this module you can:

- Name the component that runs each probe and the network path an HTTP, TCP and gRPC probe uses.
- Configure `httpGet`, `tcpSocket`, `exec` and `grpc` handlers with the correct fields.
- State the success rule of each handler: status code range, open connection, exit code, gRPC serving status.
- Read pod events to tell a wrong path, a wrong port and a failing command apart.
- Choose the handler that checks what the application can really answer.

## Before you start

You need to know what a pod, a Deployment and a Service are, and the commands `kubectl get`, `kubectl describe` and `kubectl apply`. The playground is a single-node kind cluster running Kubernetes 1.35. It has a `probe` Deployment with two replicas in the `starfleet` namespace, a `beacon` Deployment, a `shuttle` client pod in `starfleet` and a `drifter` client pod in `outpost`. The application answers on port 8080 with the paths `/`, `/ready` and `/health`, and returns status 404 for every other path.

## Reading order

The module has two parts. The first covers the `httpGet` and `tcpSocket` handlers. The second covers the `exec` and `grpc` handlers. A summary closes the module.

Launch your playground now, and keep it running next to you while you read:

<!-- astrona:playground -->
