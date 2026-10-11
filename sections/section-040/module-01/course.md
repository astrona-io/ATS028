---
draft: true
exam_objectives:
- Utilize container logs
---
# Container Logs And Lifecycle Evidence

This module connects intended application behavior to declared resources and observed conditions.

## Learning Goals

- Explain process output and container log retrieval.
- Select the relevant container and previous instance.
- Correlate records with version and observation time.
- Distinguish log evidence from startup events and infrastructure errors.

## Before You Start

Use the module playground for guided practice. It provides an isolated kind cluster and the declared starting fixtures. You need the Astrona command-line tool, kubectl and a working Podman engine; selected exercises also use Helm, curl or OpenSSL. Keep the module's private kubeconfig selected when running application commands.

## Reading Order

1. Logs, Exits And Crash Loops
2. Selecting The Right Container Log And Time Window
3. Read Current And Previous Container Logs
4. Summary

The playground provides the initial state for the guided practice. Keep it open while following the practical steps.

<!-- astrona:playground -->
