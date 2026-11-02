---
draft: true
exam_objectives:
- Understand API deprecations
---
# Migrate A Removed Deployment API

Apply a supported Deployment API with a matching selector and preserved application behavior. Use the isolated `starfleet` environment to verify the result.

## Objective

Apply a supported Deployment API with a matching selector and preserved application behavior.

## Starting state

The application and client fixtures are healthy. Complete the required change without replacing unrelated resources.

Use a host shell with this lab's private kubeconfig. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool. This environment is separate from the ungraded playground.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-028-lab-010-01-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-028-lab-010-01-01" || exit 1
```

Keep this connection selected throughout the task. Every script supplied by the lab refuses a different context.


## Required result

Create an `apps/v1` Deployment definition for `probe` with an explicit selector matching its template labels. Add template label `api-migrated: "true"`, retain two replicas and the existing application command, image, probes and configuration. Apply the supported definition and verify the Service response. The grader checks the supported server resource and result; the rejected legacy definition is a diagnostic input.

## Verify The Result

The grader checks the stated resource fields and live evidence. Wait for controller convergence before submitting. Inspect actual results rather than relying on a sample transcript.
