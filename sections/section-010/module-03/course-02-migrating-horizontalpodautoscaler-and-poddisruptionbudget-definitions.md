---
draft: true
exam_objectives:
- Understand API deprecations
---
# Migrating HorizontalPodAutoscaler And PodDisruptionBudget Definitions

The HorizontalPodAutoscaler and the PodDisruptionBudget both protect an application during change: one adds Pods under load, the other limits how many Pods a voluntary operation may remove. Their old versions were removed in Kubernetes v1.25 and v1.26. The migrations hide two different problems. The autoscaler needs a new way to write its target, and the budget keeps its fields but changes what an empty selector means.

## The autoscaler target in autoscaling/v2

A HorizontalPodAutoscaler (HPA) is a controller that changes the replica count of a Deployment to keep a metric near a target. The version `autoscaling/v2beta1` was removed in Kubernetes v1.25, and `autoscaling/v2beta2` was removed in v1.26. The supported versions are `autoscaling/v2` and the older, CPU-only `autoscaling/v1`. Use `v2`, because it supports several metrics and has the same schema as the last beta version.

In `v2beta1` the CPU target was one number: `targetAverageUtilization: 60`. In `v2` the target is an object with a `type`, and the number moves into a field named after the type:

```yaml
target:
  type: Utilization
  averageUtilization: 60
```

The value of `type` is `Utilization` for a percentage of the requested CPU, `AverageValue` for an absolute value per Pod, or `Value` for a total. The percentage is calculated against the CPU `requests` of the container, so an application without CPU requests cannot be scaled on utilization. The `probe` Deployment in the playground requests `10m` of CPU for this reason.

## Migrate the autoscaler

Extract the legacy manifest and look at the target field:

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet get configmap legacy-manifests -o jsonpath='{.data.hpa\.yaml}' > hpa.yaml
grep -n -B2 -A2 targetAverageUtilization hpa.yaml
```

The file scales the `probe` Deployment between 2 and 4 replicas at 60 percent CPU. Save the supported definition as `hpa-probe.yaml`:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: probe
  namespace: starfleet
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: probe
  minReplicas: 2
  maxReplicas: 4
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 60
```

Apply it and look at the result:

```sh
kubectl apply -f hpa-probe.yaml
kubectl -n starfleet get horizontalpodautoscalers.v2.autoscaling probe
```

The `TARGETS` column shows the current CPU use next to `60%`. Directly after the apply it can show `<unknown>` until the metrics-server has measured the Pods, which takes about a minute. If `<unknown>` stays, run `kubectl -n starfleet describe hpa probe` and read the conditions, because a missing metrics-server or a missing CPU request appears there.

## The empty selector in policy/v1

A PodDisruptionBudget (PDB) limits how many Pods of an application a voluntary disruption may remove at one time. A voluntary disruption is an action such as a node drain, in which an administrator empties a node before maintenance. The budget names the Pods with a label selector and sets `minAvailable` or `maxUnavailable`. The version `policy/v1beta1` was removed in Kubernetes v1.25 and the supported version is `policy/v1`.

The fields are the same in both versions, but one meaning changed. In `policy/v1beta1` an empty selector (`selector: {}`) selected no Pods. In `policy/v1` an empty selector selects every Pod in the namespace. A definition that only changes the version line can therefore start to protect or block Pods it never covered.

Save this as `pdb-empty-selector.yaml` to see the new meaning:

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: probe-empty
  namespace: starfleet
spec:
  minAvailable: 1
  selector: {}
```

Apply it and read the status:

```sh
kubectl apply -f pdb-empty-selector.yaml
kubectl -n starfleet describe pdb probe-empty
```

Look at the expected Pods and the current healthy count in the output. They include every Pod of the namespace, not only the `probe` Pods. Remove the test object, because it is not the migrated definition:

```sh
kubectl -n starfleet delete pdb probe-empty
```

Now migrate the real budget. Its selector names the label `app: probe`, so the version change is safe:

```sh
kubectl -n starfleet get configmap legacy-manifests -o jsonpath='{.data.pdb\.yaml}' > pdb.yaml
sed 's#policy/v1beta1#policy/v1#' pdb.yaml > pdb-v1.yaml
kubectl apply --warnings-as-errors -f pdb-v1.yaml
kubectl -n starfleet get pdb probe
```

The column `ALLOWED DISRUPTIONS` equals the number of healthy `probe` Pods minus `minAvailable`. With two healthy Pods and `minAvailable: 1`, one Pod can be removed at a time. A node drain respects this number: it waits when the budget allows no disruption.

## PodSecurityPolicy has no migration

The group `policy/v1beta1` also served PodSecurityPolicy, an admission feature that restricted what Pods could do. It was removed in Kubernetes v1.25 together with that version. There is no `policy/v1` PodSecurityPolicy, and no definition can be converted. The replacement is Pod Security Admission, a built-in admission controller that reads labels on a namespace and applies one of three levels: `privileged`, `baseline` or `restricted`.

A server-side dry run of a label change shows the effect before anything is enforced:

```sh
kubectl label --dry-run=server --overwrite namespace starfleet pod-security.kubernetes.io/enforce=restricted
```

The command stores no label. It prints a `Warning:` line for each existing Pod that would violate the `restricted` level, and the line names the Pod and the rule. Read these warnings as a list of changes that the Pod definitions need before the label can be applied for real.

You can now migrate the four resources and know where the meaning changes. The autoscaler target moves into an object, the budget keeps its fields but changes the empty selector, and a removed policy type needs a new design and not a conversion.

## Common pitfalls

> [!WARNING]
> - `targetAverageUtilization` does not exist in `autoscaling/v2`. The API server rejects the field, and the HPA does not start without a `target` object.
> - An HPA on utilization needs CPU `requests` in the Pod template and a running metrics-server. Without them `TARGETS` stays `<unknown>` and the HPA does not scale.
> - An empty `selector: {}` in `policy/v1` selects every Pod in the namespace. Always write `matchLabels` explicitly.
> - Do not look for a converter for PodSecurityPolicy. Design namespace labels for Pod Security Admission instead.
