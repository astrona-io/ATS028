# Playground: Debugging Running Pods With exec, port-forward And debug

A single-node kind cluster running Kubernetes 1.35. Nothing is graded.

## What is in the cluster

| Object | Namespace | Notes |
| --- | --- | --- |
| Deployment `probe` and Service `probe` | `starfleet` | A working web application, 2 pods |
| Pod `scout` | `starfleet` | Python web server that listens on port 9090, with `APP_VERSION=2.4.1`. The pod declares `containerPort: 8080`. |
| Service `scout` | `starfleet` | Port 80 with `targetPort: 8080`, which is the wrong port |
| Pod `shuttle` | `starfleet` | Client with `wget` |
| Pod `drifter` | `outpost` | Client in a second namespace |

## Things to try

- Print the environment of `scout` with `kubectl exec`, and list its listening sockets with `netstat -tln`.
- Request `http://scout` from `shuttle` and see it fail, then request `http://127.0.0.1:9090` from inside `scout`.
- Open `kubectl port-forward pod/scout 8081:9090` and `kubectl port-forward svc/scout 8082:80` and compare the two.
- Attach an ephemeral container with `kubectl debug` and run `ps` in it.
- Copy a file out of `scout` with `kubectl cp`.
- Correct the Service with `kubectl patch` and repeat the request from `shuttle`.
