# Application Observability and Maintenance (ATS028)

Certified Kubernetes Application Developer (CKAD): Application Observability and Maintenance, worth 15% of the curriculum and part of ATP006.

Each section has an introduction. Each module combines detailed concept readings, an ungraded isolated playground, guided practical work and a closing summary. YAML knowledge checks remain separately indexed. Technical content stays draft for review. New graded labs are not included.

## Course Outline

| Section / module | Module | Concept and practical readings |
| --- | --- | --- |
| 010 / 01 | API Discovery And Safe Definition Migration | Recognizing Deprecated APIs And Migrating Definitions; Discover A Served API And Reject A Removed Definition |
| 020 / 01 | Health Checks With Different Recovery Actions | Designing Startup, Readiness And Liveness Checks; Distinguish Readiness Removal From Liveness Restart |
| 030 / 01 | Built-In Inspection And Resource Metrics | Choosing Diagnostic Evidence With kubectl; Combine Resource Status, Events And Live Metrics |
| 040 / 01 | Container Logs And Lifecycle Evidence | Logs, Exits And Crash Loops; Selecting The Right Container Log And Time Window; Read Current And Previous Container Logs |
| 050 / 01 | Placement And Container Preparation Diagnosis | Placement And Dependency Evidence; Image Preparation And Container Startup; Locate Pending Placement And Repair A Node Selector |
| 050 / 02 | Application Dependencies And Focused Correction | Configuration, Dependencies And Request Failures; Tracing A Service Request; Repair A Missing Configuration Dependency |

## Author Review

See [curriculum coverage](CURRICULUM.md), [primary sources](SOURCES.md), [assessment contracts](ASSESSMENTS.md) and [contribution guidance](CONTRIBUTING.md). Each playground has its own config, bootstrap, guide and author smoke script. Static checks passed; live execution remains pending because the authoring session cannot access the container engine. Retain that limitation until real runtime evidence is recorded.
