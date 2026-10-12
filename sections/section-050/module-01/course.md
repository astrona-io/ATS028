---
draft: true
exam_objectives:
- Debugging in Kubernetes
---
# Placement And Container Preparation Diagnosis

A `probe` Pod is Pending because no node can satisfy its declared request and placement rules. Application logs cannot explain a process that has not started. Scheduling status and events identify this earlier boundary.

## Learning Goals

- Distinguish unscheduled work from container preparation.
- Interpret placement constraints and declared capacity.
- Diagnose registry, mount and startup dependencies.
- Choose corrections at the failing lifecycle stage.

## Before You Start

Use the module playground for guided practice. It provides an isolated kind cluster and the declared starting fixtures. You need the Astrona command-line tool, kubectl and a working Podman engine; selected exercises also use Helm, curl or OpenSSL. Keep the module's private kubeconfig selected when running application commands.

## Reading Order

1. Placement And Dependency Evidence
2. Image Preparation And Container Startup
3. Locate Pending Placement And Repair A Node Selector
4. Summary

The playground provides the initial state for the guided practice. Keep it open while following the practical steps.

<!-- astrona:playground -->
