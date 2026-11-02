---
draft: true
exam_objectives:
- Debugging in Kubernetes
---
# Starting Environment

The `probe` Deployment requests `GREETING` from a missing ConfigMap. A ConfigMap stores non-secret configuration as named keys. The kubelet cannot start the application container until the required key exists. The Service and client are already present.

Create ConfigMap `probe-settings` in `starfleet` with key `greeting` and value `welcome`. Keep the existing Deployment image, command, replica count and required `GREETING` reference. Both replicas must become ready and available. A request from `shuttle` to `http://probe/` must contain `greeting=welcome`. Do not make the reference optional or replace it with a literal environment value.
