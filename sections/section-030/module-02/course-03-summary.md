---
draft: true
exam_objectives:
- Use built-in CLI tools to monitor Kubernetes applications
---
# Summary

Label selectors and field selectors are sent to the API server, which returns only the matching objects. Label selectors support equality and set-based requirements; commas mean AND, and `in (a,b)` gives OR on one key. A negative requirement also matches objects that lack the key. Field selectors support equality only and only a few fields per resource type, such as `status.phase` and `spec.nodeName` for pods.

Output formats shape the result on the client. `-o name` gives one `kind/name` per line, `-o wide` adds columns, `-o jsonpath` prints chosen values, `-o custom-columns` prints a table you define, and `--sort-by` orders items by a JSONPath field. An empty JSONPath result can mean a wrong path.

`kubectl top` reads the Metrics API served by metrics-server, which keeps the latest sample from each kubelet. It shows current use, which is different from the requests and limits in the pod specification. Always confirm namespace, selector and metrics availability before you draw a conclusion from an empty result.

<!-- astrona:playground:destroy -->
