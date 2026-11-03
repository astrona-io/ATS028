---
draft: true
exam_objectives:
- Debugging in Kubernetes
---
# Diagnosing Failing Workloads From Status To Cause

A workload that does not work can fail at several different stages: the scheduler cannot place the pod, the kubelet cannot start the container, the process is killed after it starts, or the pod runs but no traffic reaches it. Each stage leaves its own status field and its own events. This module teaches one method for all of them: read the status, find the earliest stage that failed, confirm the cause with the evidence that stage produces, and change only what that evidence points to.

## Learning objectives

After this module you can:

- Read the `STATUS` and `READY` columns of `kubectl get pods` and map each value to the stage that failed.
- Use `kubectl describe` and events to find the reason for a `Pending` pod, an image pull failure and a container configuration error.
- Explain how `requests`, `limits` and the node allocatable capacity lead to an unschedulable pod or an `OOMKilled` container.
- Read the exit code and the `lastState` of a terminated container.
- Find a Service that has no endpoints and compare its selector with the pod labels.
- Apply a minimal correction and verify the original behavior.

## Before you start

You need to know what a Deployment, a pod and a Service are, and how to read events with `kubectl describe`. The playground is a single-node kind cluster. The `starfleet` namespace holds five Deployments that each have a different fault: `ensign`, `cadet`, `captain`, `engine` and `bridge`. It also holds a working Deployment `probe` and a client pod `shuttle`. The `outpost` namespace holds a client pod `drifter`.

## Reading order

1. Reading Status And Events To Find The Failed Stage
2. Resource Limits, Exit Codes And Service Endpoints
3. Summary

Launch your playground now and keep it open while you read:

<!-- astrona:playground -->
