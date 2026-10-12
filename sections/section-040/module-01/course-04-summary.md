---
draft: true
exam_objectives:
- Utilize container logs
---
# Summary

Logs describe a process perspective within a particular container lifecycle. Current instances, previous attempts and replaced Pods have different evidence availability.

Useful interpretation requires the right stream, time and workload identity. Missing output does not prove that startup succeeded, and a familiar error message needs additional observations to establish the actual failed dependency or operation.

Useful log evidence identifies the Pod, container, lifecycle instance and time window. Crash-loop backoff follows failed attempts; termination details and the relevant process records help explain the earlier cause.

<!-- astrona:playground:destroy -->
