---
draft: true
exam_objectives:
- Utilize container logs
---
# Multi-Container And Multi-Pod Logs

A Deployment runs several pods, and each pod can run several containers. Every container has its own log. A plain `kubectl logs` command answers for only one of them, and a selector command prints a limited number of lines from each pod. This module explains how `kubectl logs` chooses what to print, how the request travels to the node, and which options let you read the right container, the right pods and the right time window.

## Learning objectives

After this module you can:

- Name the component that serves a log request: the kubelet on the node that runs the pod.
- Select one container of a multi-container pod with `-c`, and print every container with `--all-containers`.
- Read the logs of a Deployment with `deploy/NAME` and the logs of many pods with a label selector.
- Add the pod and container name to each line with `--prefix`.
- Limit output with `--tail`, `--since` and `--timestamps`, and follow a log with `-f`.
- Explain why a selector command prints only some lines or fails with a stream limit, and raise the limit with `--max-log-requests`.
- Read the log of an init container and the log of a previous container run.

## Before you start

You need to know what a pod, a container, a Deployment and a label are. The playground is a single-node kind cluster. The `starfleet` namespace holds the Deployment `multi` with three pods of two containers each (`web` and `worker`), and the Deployment `flaky`, whose container fails on every start.

## Reading order

1. Choosing The Container And The Pod
2. Limiting, Timing And Following Logs
3. Summary

Launch your playground now and keep it open while you read:

<!-- astrona:playground -->
