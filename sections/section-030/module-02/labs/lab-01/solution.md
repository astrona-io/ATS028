# Solution: Select Workloads And Record What You Find

## Step 1. Find the production web pods

Two labels in one selector are joined with a comma, and both must match:

```sh
kubectl -n starfleet get pods -l tier=web,env=prod -o name
```

The pods of `probe` match. The pod of `scout` has `tier=web` but `env=staging`, so it does not match. The pod of `beacon` has `tier=worker`.

## Step 2. Find the distinct images

A JSONPath expression walks every pod and every container. `sort -u` removes duplicates:

```sh
kubectl -n starfleet get pods -o jsonpath='{range .items[*]}{range .spec.containers[*]}{.image}{"\n"}{end}{end}' | sort -u
```

## Step 3. Find the finished pod

The pod phase is a field, not a label, so a field selector is needed:

```sh
kubectl -n starfleet get pods --field-selector=status.phase=Succeeded -o name
```

## Step 4. Write the ConfigMap

```sh
kubectl -n starfleet create configmap findings \
  --from-literal=web-pods="$(kubectl -n starfleet get pods -l tier=web,env=prod -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')" \
  --from-literal=images="$(kubectl -n starfleet get pods -o jsonpath='{range .items[*]}{range .spec.containers[*]}{.image}{"\n"}{end}{end}' | sort -u)" \
  --from-literal=completed-pod="$(kubectl -n starfleet get pods --field-selector=status.phase=Succeeded -o jsonpath='{.items[0].metadata.name}')"
```

## Step 5. Label the pods

```sh
kubectl -n starfleet label pods -l tier=web,env=prod reviewed=true
```

The same selector that found the pods marks them, so the label and the report cannot drift apart.

## Step 6. Submit

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-030/module-02/labs/lab-01
```

The reference script `solution/apply.sh` does steps 4 and 5 in one run.
