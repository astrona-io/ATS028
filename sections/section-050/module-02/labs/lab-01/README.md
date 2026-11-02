---
draft: true
exam_objectives:
- Debugging in Kubernetes
---
# Restore A Missing ConfigMap Dependency

Diagnose a blocked container and restore its required configuration without changing the Deployment. This independent graded environment is separate from the module playground.

Author checks: run `astrona validate -c ATS028/sections/section-050/module-02/labs/lab-01` from the workspace. In a fresh lab, run `testing/smoke.sh` with its private kubeconfig to confirm that the initial state fails, the reference solution passes and convergence completes. The grader requires Python 3 on the host.

Runtime verification is pending. Static checks and offline grader tests do not prove cluster execution.
