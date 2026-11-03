---
draft: true
exam_objectives:
- Understand API deprecations
---
# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. The lab is untested, so no output is shown here; read the output on your own cluster.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-010/module-02/labs/lab-01
```

Read the old manifests before you change anything:

```sh
kubectl -n starfleet get configmap legacy-manifests -o jsonpath='{.data.role\.yaml}'
kubectl -n starfleet get configmap legacy-manifests -o jsonpath='{.data.rolebinding\.yaml}'
kubectl -n starfleet get configmap legacy-manifests -o jsonpath='{.data.priorityclass\.yaml}'
```

Each file names a `v1beta1` version. A submit now fails every check except the one that tests that the `probe` application still answers.

## Step 1: Find the served versions

Ask the cluster which versions it serves for the groups in the old files:

```sh
kubectl api-versions | grep -E 'rbac|scheduling|networking'
```

The list contains `rbac.authorization.k8s.io/v1`, `scheduling.k8s.io/v1` and `networking.k8s.io/v1` and no `v1beta1` entry for these groups. Role, RoleBinding and PriorityClass have the same fields in `v1` as in `v1beta1`, so only the version line changes.

## Step 2: Migrate the Role and the RoleBinding

Extract both files and replace the version:

```sh
kubectl -n starfleet get configmap legacy-manifests -o jsonpath='{.data.role\.yaml}' > role.yaml
kubectl -n starfleet get configmap legacy-manifests -o jsonpath='{.data.rolebinding\.yaml}' > rolebinding.yaml
sed 's#rbac.authorization.k8s.io/v1beta1#rbac.authorization.k8s.io/v1#' role.yaml > role-v1.yaml
sed 's#rbac.authorization.k8s.io/v1beta1#rbac.authorization.k8s.io/v1#' rolebinding.yaml > rolebinding-v1.yaml
```

Validate both on the server, then apply them:

```sh
kubectl apply --dry-run=server -f role-v1.yaml -f rolebinding-v1.yaml
kubectl apply --warnings-as-errors -f role-v1.yaml -f rolebinding-v1.yaml
```

Ask the authorization system what `scout-reader` can do. Reading pods and logs must give `yes`, and deleting pods must give `no`:

```sh
kubectl auth can-i get pods/log -n starfleet --as=system:serviceaccount:starfleet:scout-reader
kubectl auth can-i delete pods -n starfleet --as=system:serviceaccount:starfleet:scout-reader
```

Submit and read the result of the checks `role-and-binding-migrated` and `least-privilege`:

```sh
astrona submit --keep --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-010/module-02/labs/lab-01
```

## Step 3: Migrate the PriorityClass

A PriorityClass is a cluster-wide object, so the file has no namespace. The `sed` pattern is the same with another group:

```sh
kubectl -n starfleet get configmap legacy-manifests -o jsonpath='{.data.priorityclass\.yaml}' > priorityclass.yaml
sed 's#scheduling.k8s.io/v1beta1#scheduling.k8s.io/v1#' priorityclass.yaml > priorityclass-v1.yaml
kubectl apply --warnings-as-errors -f priorityclass-v1.yaml
kubectl get priorityclasses.v1.scheduling.k8s.io fleet-critical
```

The name `priorityclasses.v1.scheduling.k8s.io` reads the object in the supported version and shows the value `900000`. Submit again and read the result of `priorityclass-migrated`.

## Step 4: Record the findings

Save this as `configmap-api-findings.yaml`. The values come from the discovery output in the first step:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: api-findings
  namespace: starfleet
data:
  role: rbac.authorization.k8s.io/v1
  priorityclass: scheduling.k8s.io/v1
  ingress: networking.k8s.io/v1
```

Apply it:

```sh
kubectl apply -f configmap-api-findings.yaml
```

Then check the result:

```sh
kubectl -n starfleet get configmap api-findings -o jsonpath='{.data}'
kubectl -n starfleet get deployment probe
```

The Deployment must still show two ready replicas. Submit a last time and confirm that all five checks pass:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-010/module-02/labs/lab-01
```

When you are done, remove the lab:

```sh
astrona destroy ats-028-lab-010-02-01
```
