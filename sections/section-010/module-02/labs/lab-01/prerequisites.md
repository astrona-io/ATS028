---
draft: true
exam_objectives:
- Understand API deprecations
---
# Prerequisites

Use a host shell with the Astrona command-line tool, kubectl (the Kubernetes command-line tool) and a running container engine. The lab starts a kind cluster that runs Kubernetes v1.35.0 and uses its own kubeconfig, the file that tells kubectl which cluster and credentials to use.

You need to know how to read a manifest, extract a value with jsonpath, apply a file with `kubectl apply`, and ask the API server which versions it serves with `kubectl api-versions`.
