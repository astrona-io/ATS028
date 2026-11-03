---
draft: true
exam_objectives:
- Use built-in CLI tools to monitor Kubernetes applications
---
# Summary

A Deployment changes through ReplicaSets. A change to the pod template creates a new ReplicaSet and a new revision, and `maxSurge` and `maxUnavailable` set the pace. If new pods do not become Ready, old pods stay in service, the rollout is stuck, and the controller does not roll back by itself. `kubectl rollout status` reports progress and exits non-zero on failure, `rollout history` lists revisions and `--revision=N` shows the template of one, and `rollout undo` returns to an earlier template. The `kubernetes.io/change-cause` annotation records the reason as free text.

Events describe what controllers, the scheduler and the kubelet did. They expire after about an hour. `kubectl events` sorts by time and filters with `--for` and `--types`; `describe` shows the events of one object in lifecycle order, and each missing step names the stage that failed. Watch mode streams changes, and `kubectl wait` blocks until a condition is true so that scripts do not guess.

<!-- astrona:playground:destroy -->
