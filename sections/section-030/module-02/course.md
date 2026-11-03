---
draft: true
exam_objectives:
- Use built-in CLI tools to monitor Kubernetes applications
---
# Selecting And Shaping kubectl Output

A cluster holds hundreds of objects, and a plain `kubectl get` prints all of them. Observing an application means asking for exactly the objects and fields that answer one question. `kubectl` has two selection mechanisms, label selectors and field selectors, and several output formats that shape the result. This module explains where each mechanism runs, which attributes it can see and how to turn the output into a table, a list of names or a single value.

## Learning objectives

After this module you can:

- Select objects with equality-based and set-based label selectors, and combine several requirements.
- Select objects with field selectors, and name the fields that support them.
- State which side evaluates a selector: the API server filters before the response is sent.
- Print names, wide output, custom columns, JSONPath values and sorted lists.
- Read live CPU and memory use with `kubectl top` and name its data source.

## Before you start

You need to know what a pod, a label and a namespace are. The playground is a single-node kind cluster with the metrics-server add-on. The `starfleet` namespace holds the Deployments `probe`, `beacon` and `scout`, a Service `probe`, a finished Job `report-job` and a client pod `shuttle`. The `outpost` namespace holds a client pod `drifter`.

## Reading order

1. Label And Field Selectors
2. Output Formats, Sorting And Resource Usage
3. Summary

Launch your playground now and keep it open while you read:

<!-- astrona:playground -->
