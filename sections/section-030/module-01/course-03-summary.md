---
draft: true
exam_objectives:
- Use built-in CLI tools to monitor Kubernetes applications
---
# Summary

Diagnostic observations have a scope and a purpose. Specification, status, temporary events, metrics and process output provide different evidence about an application.

The correct cluster, namespace and identity must be established before interpreting missing data. Select each observation to test a concrete cause, distinguishing preparation, runtime and traffic failures rather than collecting unrelated output.

A diagnosis connects desired state, observed status, events and measured usage to one symptom. Timing and permissions limit each observation, and current usage cannot substitute for the scheduler's resource request contract.

<!-- astrona:playground:destroy -->
