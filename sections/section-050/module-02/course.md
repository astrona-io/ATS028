---
draft: true
exam_objectives:
- Debugging in Kubernetes
---
# Application Dependencies And Focused Correction

The `probe` application runs, but its effective settings differ from the intended values. Configuration can arrive through environment variables, mounted files and application defaults. Diagnose the value actually used rather than assuming the newest object is already effective.

## Learning Goals

- Trace a request through application dependencies.
- Distinguish configuration, identity and network failures.
- Compare process health with useful request behavior.
- Select a focused correction and verify the intended result.

## Before You Start

Use the module playground for guided practice. It provides an isolated kind cluster and the declared starting fixtures. You need the Astrona command-line tool, kubectl and a working Podman engine; selected exercises also use Helm, curl or OpenSSL. Keep the module's private kubeconfig selected when running application commands.

## Reading Order

1. Configuration, Dependencies And Request Failures
2. Tracing A Service Request
3. Repair A Missing Configuration Dependency
4. Summary

The playground provides the initial state for the guided practice. Keep it open while following the practical steps.

<!-- astrona:playground -->
