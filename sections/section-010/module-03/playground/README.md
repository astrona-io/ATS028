# Migrating Ingress, CronJob, HorizontalPodAutoscaler And PodDisruptionBudget Playground

Ungraded module environment: `ats-028-playground-010-03`. Kubernetes v1.35.0 is pinned by node image digest. No validation block is registered in `config.yaml`.

```sh
astrona validate -c .
astrona run -c .
astrona destroy ats-028-playground-010-03
```

The [environment guide](docs/overview.md) describes the fixtures. The `legacy-manifests` ConfigMap carries manifests for removed API versions as text, because the API server cannot store them.

Status: UNTESTED - authored without running the playground.
