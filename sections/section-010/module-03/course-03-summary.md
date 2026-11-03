---
draft: true
exam_objectives:
- Understand API deprecations
---
# Summary

A migration checks three things: the version that the API server serves, the fields of that version, and the behavior of the resource. The old versions of Ingress, CronJob, HorizontalPodAutoscaler and PodDisruptionBudget were removed in Kubernetes v1.22, v1.25 and v1.26, and each has a supported replacement.

An Ingress in `networking.k8s.io/v1` writes its backend as `service.name` and `service.port.number`, requires a `pathType` on every path and selects the controller with `spec.ingressClassName` instead of an annotation. A CronJob in `batch/v1` keeps the same fields as the beta version, so only the `apiVersion` changes. A Job created from the CronJob template tests the Pod template without waiting for the schedule.

A HorizontalPodAutoscaler in `autoscaling/v2` writes its CPU target as an object with `type: Utilization` and `averageUtilization`. The utilization is calculated against the CPU requests of the Pods, and the autoscaler reads the values from the metrics-server. A PodDisruptionBudget in `policy/v1` keeps its fields, but an empty selector now selects every Pod in the namespace, so the selector must name the labels of the application.

PodSecurityPolicy was removed with `policy/v1beta1` and has no converted form. Pod Security Admission replaces it and works through namespace labels, and a server-side dry run of a label change previews the effect.

Key facts:

- Ingress: `serviceName` and `servicePort` become `service.name` and `service.port.number`.
- HorizontalPodAutoscaler: `targetAverageUtilization` becomes `target.type` and `target.averageUtilization`.
- PodDisruptionBudget: `selector: {}` selected no Pods in the beta version and selects all Pods in `v1`.
- A version change alone is enough only for the CronJob.

<!-- astrona:playground:destroy -->
