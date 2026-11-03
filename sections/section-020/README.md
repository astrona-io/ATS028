---
draft: true
exam_objectives:
- Implement probes and health checks
---
# Implement probes and health checks

This section covers implement probes and health checks. You will study Health Checks With Different Recovery Actions, Probe Handlers: HTTP, TCP, Exec And gRPC, Probe Timing And Startup Probes. The lessons explain the responsible components, configuration relationships and failure cases relevant to application development.

Each module begins with its goals and ends with a summary. The section closes with a capstone lab and a knowledge check quiz.


You will assign health evidence to its intended action. Startup gates regular checks, readiness controls traffic eligibility and liveness can trigger replacement. Read the actual configured endpoint and threshold before interpreting a restart or missing backend.

## Learning Outcomes

- Distinguish startup, readiness and liveness actions.
- Choose a meaningful supported probe type.
- Evaluate thresholds and expected initialization time.
- Diagnose restarts separately from missing ready endpoints.

Each module pairs its concept readings with a guided practical sequence in an isolated playground. Finish the practice and closing summary before moving on. The capstone combines the skills of every module in one task, and the quiz has 10 questions.

## Contents

- Health Checks With Different Recovery Actions: Designing Startup, Readiness And Liveness Checks, Distinguish Readiness Removal From Liveness Restart, Summary. Playground and 2 graded labs.
- Probe Handlers: HTTP, TCP, Exec And gRPC: HTTP And TCP Probes, Exec And gRPC Probes, Summary. Playground and 1 graded lab.
- Probe Timing And Startup Probes: Probe Timing Fields, Startup Probes, Summary. Playground and 1 graded lab.
- Capstone: Repair And Add Probes On Three Workloads
- Knowledge check: `quiz.yaml`
