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

## Hands-On Expansion

Playgrounds and guided practical readings were added on 2026-10-12. Every existing module retains its concept readings and gains one practical reading before its renumbered summary. YAML bank placement follows the new summary path. Official weights, objective IDs and ATP006 links are unchanged. Runtime verification is pending; static checks do not establish successful cluster execution.

## Graded Lab Expansion

Every active module includes a draft independent graded lab. This course has 7 active graded labs, registered after the readings they practise. Each has its own cluster, task, solution, context guards, reference repair and behavior grader. Static and offline checks pass. Live verification remains pending because the authoring session cannot access the Podman socket. The installed CLI's configuration validator is separately blocked by its local-state maintenance lock.

| Module | Labs in teaching order |
| --- | --- |
| 010/01 | Migrate A Removed Deployment API |
| 020/01 | Repair Readiness Without Removing It; Repair A Liveness Probe Port |
| 030/01 | Capture Live Pod Metrics |
| 040/01 | Diagnose A Previous Container Exit |
| 050/01 | Repair An Impossible Node Selector |
| 050/02 | Restore A Missing ConfigMap Dependency |
