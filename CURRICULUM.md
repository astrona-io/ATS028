# Curriculum Coverage

Exam: Certified Kubernetes Application Developer (CKAD). Domain: Application Observability and Maintenance (15%).

The [official objectives](https://training.linuxfoundation.org/certification/certified-kubernetes-application-developer-ckad/) were verified on 2026-10-11. Teaching structure is original; it does not add official exam requirements.

| Section | Official objective | Modules |
| --- | --- | --- |
| 010 | Understand API deprecations | 1 |
| 020 | Implement probes and health checks | 1 |
| 030 | Use built-in CLI tools to monitor Kubernetes applications | 1 |
| 040 | Utilize container logs | 1 |
| 050 | Debugging in Kubernetes | 2 |

| Section / module | Module | Teaching lessons |
| --- | --- | --- |
| 010 / 01 | API Discovery And Safe Definition Migration | Recognizing Deprecated APIs And Migrating Definitions |
| 020 / 01 | Health Checks With Different Recovery Actions | Designing Startup, Readiness And Liveness Checks |
| 030 / 01 | Built-In Inspection And Resource Metrics | Choosing Diagnostic Evidence With kubectl |
| 040 / 01 | Container Logs And Lifecycle Evidence | Logs, Exits And Crash Loops; Selecting The Right Container Log And Time Window |
| 050 / 01 | Placement And Container Preparation Diagnosis | Placement And Dependency Evidence; Image Preparation And Container Startup |
| 050 / 02 | Application Dependencies And Focused Correction | Configuration, Dependencies And Request Failures; Tracing A Service Request |

The module goals and adaptation sources are recorded in AUTHORING.yaml. Every official objective is covered. Each section starts with an introduction, and each module ends with a summary. YAML banks follow the relevant summary and remain separate from the Markdown manifest.

This is a reading-only draft. No new labs, playgrounds, command output or runtime verification are included. ATP006 publication remains draft.
