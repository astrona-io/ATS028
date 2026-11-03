---
draft: true
exam_objectives:
- Debugging in Kubernetes
---
# Summary

`kubectl exec` sends a command through the API server to the kubelet on the node, which starts the command inside the namespaces of the chosen container. It shows the environment variables, files and sockets that the process itself sees. The command must exist in the container image, so a minimal image may have no shell at all. In a pod with several containers, `-c` selects the container; without it `kubectl` uses the default container.

`kubectl port-forward` opens a local listening port and carries each connection through the API server and the kubelet to a port in the pod network namespace. It does not use the Service. When the target is a Service or a Deployment, `kubectl` picks one pod and forwards to that pod. The forward ends when the command stops or the pod goes away.

`kubectl debug` adds an ephemeral container to a running pod. The container has its own image with the tools you need, shares the network namespace of the pod, and can share the process namespace of a target container with `--target`. It cannot be removed or changed after it is added. `kubectl debug --copy-to` instead creates a modified copy of the pod. `kubectl cp` streams a tar archive through `exec`, so it needs `tar` in the container.

Three numbers must agree for a Service to work: the port the process listens on, the `targetPort` of the Service and the traffic that clients send to the Service port. The `containerPort` field is documentation only and does not open or close a port. Read the listening port from inside the container, then fix the Service, not the evidence.

<!-- astrona:playground:destroy -->
