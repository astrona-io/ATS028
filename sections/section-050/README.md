---
draft: true
exam_objectives:
- Debugging in Kubernetes
---
# Debugging in Kubernetes

This section covers debugging in Kubernetes. You will study Placement And Container Preparation Diagnosis, Application Dependencies And Focused Correction, Debugging Running Pods With exec, port-forward And debug, Diagnosing Failing Workloads From Status To Cause. The lessons explain the responsible components, configuration relationships and failure cases relevant to application development.

Each module begins with its goals and ends with a summary. The section closes with a capstone lab and a knowledge check quiz.


You will locate the earliest unresolved application boundary. Placement, image preparation, process startup, configuration adoption and request routing leave different evidence. A focused correction preserves the original caller and operation when verifying recovery.

## Learning Outcomes

- Distinguish unscheduled work from container preparation.
- Interpret placement constraints and declared capacity.
- Diagnose registry, mount and startup dependencies.
- Choose corrections at the failing lifecycle stage.
- Trace a request through application dependencies.
- Distinguish configuration, identity and network failures.
- Compare process health with useful request behavior.
- Select a focused correction and verify the intended result.

Each module pairs its concept readings with a guided practical sequence in an isolated playground. Finish the practice and closing summary before moving on. The capstone combines the skills of every module in one task, and the quiz has 10 questions.

## Contents

- Placement And Container Preparation Diagnosis: Placement And Dependency Evidence, Image Preparation And Container Startup, Locate Pending Placement And Repair A Node Selector, Summary. Playground and 1 graded lab.
- Application Dependencies And Focused Correction: Configuration, Dependencies And Request Failures, Tracing A Service Request, Repair A Missing Configuration Dependency, Summary. Playground and 1 graded lab.
- Debugging Running Pods With exec, port-forward And debug: Running Commands And Tunnels With exec And port-forward, Ephemeral Containers And File Copy, Summary. Playground and 1 graded lab.
- Diagnosing Failing Workloads From Status To Cause: Reading Status And Events To Find The Failed Stage, Resource Limits, Exit Codes And Service Endpoints, Summary. Playground and 1 graded lab.
- Capstone: Debug A Release With Three Problems
- Knowledge check: `quiz.yaml`
