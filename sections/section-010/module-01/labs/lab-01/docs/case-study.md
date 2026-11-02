---
draft: true
exam_objectives:
- Understand API deprecations
---
# Starting Environment

The application and client fixtures are healthy. Complete the required change without replacing unrelated resources.

Create an `apps/v1` Deployment definition for `probe` with an explicit selector matching its template labels. Add template label `api-migrated: "true"`, retain two replicas and the existing application command, image, probes and configuration. Apply the supported definition and verify the Service response. The grader checks the supported server resource and result; the rejected legacy definition is a diagnostic input.
