# Application Observability and Maintenance (ATS028)

Certified Kubernetes Application Developer (CKAD): Application Observability and Maintenance, worth 15% of the curriculum and part of ATP006.

Each section has an introduction, modules, a capstone lab and a knowledge check quiz. Each module combines detailed concept readings, an ungraded isolated playground, a graded lab and a closing summary. A final domain quiz covers all five sections. Technical content stays draft for review.

## Course Outline

| Section / module | Module | Concept readings |
| --- | --- | --- |
| 010 / 01 | API Discovery And Safe Definition Migration | Recognizing Deprecated APIs And Migrating Definitions; Discover A Served API And Reject A Removed Definition |
| 010 / 02 | Deprecation Policy, Warnings And Detection | Deprecation Policy And Server Signals; Finding Deprecated API Use And Converting Definitions |
| 010 / 03 | Migrating Ingress, CronJob, HorizontalPodAutoscaler And PodDisruptionBudget Definitions | Migrating Ingress And CronJob Definitions; Migrating HorizontalPodAutoscaler And PodDisruptionBudget Definitions |
| 020 / 01 | Health Checks With Different Recovery Actions | Designing Startup, Readiness And Liveness Checks; Distinguish Readiness Removal From Liveness Restart |
| 020 / 02 | Probe Handlers: HTTP, TCP, Exec And gRPC | HTTP And TCP Probes; Exec And gRPC Probes |
| 020 / 03 | Probe Timing And Startup Probes | Probe Timing Fields; Startup Probes |
| 030 / 01 | Built-In Inspection And Resource Metrics | Choosing Diagnostic Evidence With kubectl; Combine Resource Status, Events And Live Metrics |
| 030 / 02 | Selecting And Shaping kubectl Output | Label And Field Selectors; Output Formats, Sorting And Resource Usage |
| 030 / 03 | Rollouts, Events And Watching Change | Rollouts, Revisions And Rollback; Events, Watching And Waiting |
| 040 / 01 | Container Logs And Lifecycle Evidence | Logs, Exits And Crash Loops; Selecting The Right Container Log And Time Window; Read Current And Previous Container Logs |
| 040 / 02 | Multi-Container And Multi-Pod Logs | Choosing The Container And The Pod; Limiting, Timing And Following Logs |
| 040 / 03 | Logging Architecture And Sidecars | From Container Output To Node Log Files; Node-Level Logging And The Sidecar Pattern |
| 050 / 01 | Placement And Container Preparation Diagnosis | Placement And Dependency Evidence; Image Preparation And Container Startup; Locate Pending Placement And Repair A Node Selector |
| 050 / 02 | Application Dependencies And Focused Correction | Configuration, Dependencies And Request Failures; Tracing A Service Request; Repair A Missing Configuration Dependency |
| 050 / 03 | Debugging Running Pods With exec, port-forward And debug | Running Commands And Tunnels With exec And port-forward; Ephemeral Containers And File Copy |
| 050 / 04 | Diagnosing Failing Workloads From Status To Cause | Reading Status And Events To Find The Failed Stage; Resource Limits, Exit Codes And Service Endpoints |

## Graded Labs

This course has 17 module labs and 5 capstone labs, listed after the readings they practise. Each has its own cluster, task, solution, bootstrap, reference solution and validation scripts. Every lab and playground passed `astrona validate -c` and `bash -n`. No lab or playground has been run: all are untested until `astrona test` has been run on them.

| Module | Labs in teaching order |
| --- | --- |
| 010/01 | Migrate A Removed Deployment API |
| 010/02 | Migrate Role, RoleBinding And PriorityClass Definitions |
| 010/03 | Migrate Ingress, CronJob, HorizontalPodAutoscaler And PodDisruptionBudget |
| 010/capstone | Migrate An Old Release To The Supported APIs |
| 020/01 | Repair Readiness Without Removing It; Repair A Liveness Probe Port |
| 020/02 | Fix And Add Probe Handlers |
| 020/03 | Size A Startup Probe |
| 020/capstone | Repair And Add Probes On Three Workloads |
| 030/01 | Capture Live Pod Metrics |
| 030/02 | Select Workloads And Record What You Find |
| 030/03 | Diagnose And Roll Back A Stuck Rollout |
| 030/capstone | Inspect A Fleet And Roll Back A Failed Update |
| 040/01 | Diagnose A Previous Container Exit |
| 040/02 | Read Logs From Multi-Container And Crashing Pods |
| 040/03 | Ship A File Log To Standard Output With A Sidecar |
| 040/capstone | Read Container Logs And Add A Log Sidecar |
| 050/01 | Repair An Impossible Node Selector |
| 050/02 | Restore A Missing ConfigMap Dependency |
| 050/03 | Inspect A Running Pod And Correct Its Service |
| 050/04 | Diagnose And Repair Five Failing Workloads |
| 050/capstone | Debug A Release With Three Problems |

## Quizzes

Each section has `quiz.yaml` with 10 single choice questions, and `sections/final-domain-quiz.yaml` has 25 questions across all sections. Pass score is 70 percent. The questions are original practice material with status draft.

## Author Review

See [curriculum coverage](CURRICULUM.md), [primary sources](SOURCES.md), [assessment contracts](ASSESSMENTS.md) and [contribution guidance](CONTRIBUTING.md).
