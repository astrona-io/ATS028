---
draft: true
exam_objectives:
- Utilize container logs
---
# Logging Architecture And Sidecars

`kubectl logs` shows what a container wrote to standard output and standard error, and nothing else. A container that writes to a file shows an empty log, and a log that the node has rotated or deleted is gone. This module explains how the container runtime and the kubelet turn container output into log files on the node, how those files are rotated and removed, and how a sidecar container makes a file log visible to `kubectl logs`.

## Learning objectives

After this module you can:

- Explain what the container runtime and the kubelet do with standard output and standard error.
- Find the log files of a pod on the node under `/var/log/pods` and `/var/log/containers`.
- Describe log rotation with the kubelet settings `containerLogMaxSize` and `containerLogMaxFiles`.
- State when container logs are lost, for example when a pod is deleted.
- Compare node-level logging with the sidecar pattern.
- Share a log file between two containers with an `emptyDir` volume and stream it with a sidecar.

## Before you start

You need to know what a pod, a container, a Deployment and a volume are. The playground is a single-node kind cluster. The `starfleet` namespace holds three Deployments: `stdout-app` writes to standard output, `file-app` writes only to a file, and `sidecar-app` writes to a file and has a second container that prints the file.

## Reading order

1. From Container Output To Node Log Files
2. Node-Level Logging And The Sidecar Pattern
3. Summary

Launch your playground now and keep it open while you read:

<!-- astrona:playground -->
