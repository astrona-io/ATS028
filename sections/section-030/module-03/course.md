---
draft: true
exam_objectives:
- Use built-in CLI tools to monitor Kubernetes applications
---
# Rollouts, Events And Watching Change

An application changes while you observe it. A new image is rolled out, pods restart, a readiness check fails and recovers. `kubectl` has commands that report on change over time: `rollout status` and `rollout history` for Deployments, `events` for what the cluster did and why, and watch mode for live updates. This module explains what state each command reads, how long that state is kept and how to combine the commands to find the cause of a stuck update.

## Learning objectives

After this module you can:

- Explain how a Deployment rollout works through ReplicaSets and which fields control its pace.
- Read `kubectl rollout status` and `kubectl rollout history`, and roll back to a revision.
- Record a change reason with the `kubernetes.io/change-cause` annotation.
- Read events, filter them by object and type, and state how long they are kept.
- Watch objects change with `-w`, and block on a condition with `kubectl wait`.

## Before you start

You need to know what a Deployment and a ReplicaSet are and the commands from the previous module. The playground is a single-node kind cluster. The `starfleet` namespace holds the Deployments `probe` and `beacon` with two replicas each, a Service `probe` and a client pod `shuttle`. The `outpost` namespace holds a client pod `drifter`.

## Reading order

1. Rollouts, Revisions And Rollback
2. Events, Watching And Waiting
3. Summary

Launch your playground now and keep it open while you read:

<!-- astrona:playground -->
