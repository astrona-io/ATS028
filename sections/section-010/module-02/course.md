---
draft: true
exam_objectives:
- Understand API deprecations
---
# Deprecation Policy, Warnings And Detection

A cluster upgrade can remove an API version that a manifest still uses. The manifest then fails with an error, even though nothing was wrong the day before. This module explains the rules that decide when a version is removed, the signals the API server gives before that happens, and the commands that find old definitions while they still work.

## Learning objectives

- Explain the alpha, beta and GA (generally available) stability levels and how long a deprecated version must keep working.
- Tell a deprecated API version, which still works and warns, from a removed one, which fails.
- Read the Warning header, the audit annotation and the `apiserver_requested_deprecated_apis` metric.
- Use `kubectl api-versions`, `kubectl api-resources`, `kubectl explain`, `--dry-run=server` and `--warnings-as-errors` to check a definition.
- Change the `apiVersion` of a definition and confirm that the permissions and behavior it defines stay the same.

## Before you start

Use a shell on your own machine with the module playground running. You need the Astrona command-line tool and kubectl, the Kubernetes command-line tool. The playground is a kind cluster (Kubernetes running in containers) that runs Kubernetes v1.35.0.

The playground holds the `probe` Deployment in the `starfleet` namespace and a ConfigMap named `legacy-manifests` with four old manifests. A ConfigMap is an object that stores named text values. The old manifests live inside it because a removed API version cannot be stored in a cluster, but the text of a manifest can.

## Reading order

1. Deprecation Policy And Server Signals
2. Finding Deprecated API Use And Converting Definitions
3. Summary

Keep the playground open while you read. A graded lab follows the second reading.

<!-- astrona:playground -->
