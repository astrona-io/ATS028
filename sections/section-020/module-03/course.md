---
draft: true
exam_objectives:
- Implement probes and health checks
---
# Probe Timing And Startup Probes

A probe with the right handler can still do damage when its timing is wrong. A liveness probe that starts too early kills a slow application before it listens. A readiness probe that waits too long keeps a healthy pod out of the Service. Kubernetes gives you five timing fields on every probe and a separate probe type, the startup probe, for applications that need a long time to start.

This module explains what each timing field controls, how to calculate when a container is restarted or removed from a Service, and how a startup probe holds back the other probes. You will break a slow application on purpose and repair it with arithmetic instead of guessing.

## Learning objectives

After this module you can:

- Name the five timing fields and their defaults.
- Calculate how long a failing container survives before a restart.
- Explain how readiness failures change Service endpoints without restarting anything.
- Explain what a startup probe disables while it runs and what happens when it fails.
- Size a startup probe for an application with a known maximum start time.

## Before you start

You need the probe handlers from the previous module: `httpGet`, `tcpSocket`, `exec` and `grpc`. The playground has a Deployment `probe` that starts at once and a Deployment `slow` that waits 30 seconds before it listens on port 8080. Both run in the namespace `starfleet`.

## Reading order

Part one covers the timing fields and the arithmetic. Part two covers the startup probe. A summary closes the module.

Launch your playground now, and keep it running next to you while you read:

<!-- astrona:playground -->
