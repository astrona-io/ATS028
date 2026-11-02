---
draft: true
exam_objectives:
- Implement probes and health checks
---
# Health Checks With Different Recovery Actions

The `probe` process can remain running while readiness removes it from Service traffic. A liveness failure would instead request a restart. Choosing the correct check prevents a temporary dependency failure from causing unnecessary process replacement.

## Learning Goals

- Distinguish startup, readiness and liveness actions.
- Choose a meaningful supported probe type.
- Evaluate thresholds and expected initialization time.
- Diagnose restarts separately from missing ready endpoints.

## Before You Start

Use the module playground for guided practice. It provides an isolated kind cluster and the declared starting fixtures. You need the Astrona command-line tool, kubectl and a working Podman engine; selected exercises also use Helm, curl or OpenSSL. Keep the module's private kubeconfig selected when running application commands.

## Reading Order

1. Designing Startup, Readiness And Liveness Checks
2. Distinguish Readiness Removal From Liveness Restart
3. Summary

The playground provides the initial state for the guided practice. Keep it open while following the practical steps.

<!-- astrona:playground -->
