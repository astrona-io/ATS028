---
draft: true
exam_objectives:
- Utilize container logs
---
# Summary

A container log belongs to one container of one pod. The container runtime on the node writes the standard output and standard error of the container to a file, and the kubelet serves that file. A `kubectl logs` request travels through the API server to the kubelet of the node that runs the pod. If that node is not reachable, the log is not reachable, even when the pod object exists.

When a pod has several containers, `kubectl` prints the default container and warns on standard error. The flag `-c` names a container, including an init container, and `--all-containers` prints all of them. The flag `--prefix` adds the pod and container name to every line, which is needed when the same text comes from several pods. A resource such as `deploy/NAME` reads one pod. A label selector with `-l` reads all matching pods.

Selector commands apply their own limits. Each pod gives only its last 10 lines unless `--tail` says otherwise, and following more than 5 streams needs `--max-log-requests`. The options `--since`, `--since-time` and `--timestamps` bound and date the output, and `grep` filters it on the client. For a container that already ended or crashed, `--previous` reads the last finished run. The kubelet keeps only that run, and it deletes the logs with the pod.

<!-- astrona:playground:destroy -->
