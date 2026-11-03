---
draft: true
exam_objectives:
- Utilize container logs
---
# Summary

Kubernetes does not give an application a logging interface. The container runtime captures the standard output and standard error of each container process and writes the lines to a file on the node, in a format that carries a timestamp, the stream name and a full or partial line tag. The kubelet creates the directories under `/var/log/pods`, links each container log under `/var/log/containers`, and reads the files back when `kubectl logs` asks through the API server. A file that an application writes inside its own filesystem never enters this path, so `kubectl logs` shows nothing for it.

The kubelet also limits the files. It rotates a container log at `containerLogMaxSize` (default 10Mi) and keeps `containerLogMaxFiles` files (default 5), and `kubectl logs` reads only the current file. A container restart keeps the previous run, but deleting a pod removes its log files, including when a Deployment replaces the pod. Logs that must outlive a pod have to be copied off the node while the pod runs.

Two patterns cover this. Node-level logging runs an agent on every node that reads the node log files and sends them to a central store, with no change to the pods. A sidecar runs in the same pod as the application. A streaming sidecar mounts an `emptyDir` volume that the application also mounts, reads the log file and prints it to its own standard output, so the normal path and `kubectl logs -c` work again. The `emptyDir` volume lives as long as the pod, and the pattern stores each line twice, so standard output remains the preferred choice for code you control.

<!-- astrona:playground:destroy -->
