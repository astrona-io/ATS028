---
estimated_duration: 25m
---

# Lab: Migrate Role, RoleBinding And PriorityClass Definitions

Graded lab for the deprecation detection module. The cluster starts with the `probe` application in `starfleet`, the service account `scout-reader` and a ConfigMap `legacy-manifests` with three manifests for removed API versions. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-010/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-010/module-02/labs/lab-01
astrona destroy ats-028-lab-010-02-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-role-and-binding-migrated.sh` | Role and RoleBinding `scout-reader` are readable in `rbac.authorization.k8s.io/v1` and `scout-reader` can read pods and pod logs |
| `validate-least-privilege.sh` | `scout-reader` cannot delete, create or read secrets, has no rights in `outpost` and has no wildcard rights |
| `validate-priorityclass-migrated.sh` | PriorityClass `fleet-critical` exists in `scheduling.k8s.io/v1` with value 900000 and is not the global default |
| `validate-findings-recorded.sh` | ConfigMap `api-findings` holds the served group and version of Role, PriorityClass and Ingress |
| `validate-probe-still-serving.sh` | The `probe` Deployment has two ready replicas and `shuttle` receives `version=v1` |

Status: UNTESTED - authored without running the lab.
