---
draft: true
exam_objectives:
- Debugging in Kubernetes
---
# Summary

A pod passes through ordered stages: scheduling, image pull, container creation, process start, readiness and traffic. The `STATUS` column and the events show the earliest stage that failed. A pod in `Pending` has not been placed on a node, and the `PodScheduled` condition and the `FailedScheduling` event give the reason. A pod in `ErrImagePull` or `ImagePullBackOff` has a node but cannot get the image. A pod in `CreateContainerConfigError` cannot build the container, often because a referenced ConfigMap or Secret key does not exist.

A container that starts and then stops leaves a termination record in `lastState`. Exit code 137 together with the reason `OOMKilled` means the kernel ended the process because it used more memory than its limit. The scheduler uses `requests` to place a pod, and a request larger than the allocatable capacity of every node keeps the pod `Pending`. The runtime enforces `limits` after the process starts.

A pod that runs does not guarantee that a client can reach it. A Service sends traffic to the endpoints that its label selector matches among ready pods. An empty endpoint list usually means that the selector and the pod labels differ. Each fault has a different correction, so the method is to read the status, confirm with the evidence of that stage, change one thing and repeat the original request to prove that the behavior returned.

<!-- astrona:playground:destroy -->
