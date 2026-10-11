---
draft: true
exam_objectives:
- Use built-in CLI tools to monitor Kubernetes applications
---
# Built-In Inspection And Resource Metrics

This module connects intended application behavior to declared resources and observed conditions.

## Learning Goals

- Identify cluster, namespace and identity context.
- Compare desired specification, status and events.
- Distinguish resource usage from declared allocation.
- Choose diagnostic commands for the observed lifecycle stage.

## Before You Start

Use the module playground for guided practice. It provides an isolated kind cluster and the declared starting fixtures. You need the Astrona command-line tool, kubectl and a working Podman engine; selected exercises also use Helm, curl or OpenSSL. Keep the module's private kubeconfig selected when running application commands.

## Reading Order

1. Choosing Diagnostic Evidence With kubectl
2. Combine Resource Status, Events And Live Metrics
3. Summary

The playground provides the initial state for the guided practice. Keep it open while following the practical steps.

<!-- astrona:playground -->
