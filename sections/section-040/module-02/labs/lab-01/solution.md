# Solution: Read Logs From Multi-Container And Crashing Pods

## Step 1. Find the containers and the pods

List the pods and read the container names from the Deployment:

```sh
kubectl -n starfleet get pods -l app=ledger
kubectl -n starfleet get deployment ledger -o jsonpath='{.spec.template.spec.containers[*].name}{"\n"}'
```

Three pods are listed with `2/2` ready. The container names are `api` and `audit`. Sorted and joined with a comma, they are `api,audit`.

## Step 2. Read the audit container only

```sh
kubectl -n starfleet logs deploy/ledger -c audit --tail=30 | grep ERROR
```

`deploy/ledger` reads one pod, and `-c audit` selects the container. Without `-c`, `kubectl` would print the `api` container. A line looks like `audit ERROR code=E417 entry=3`. The code is the value after `code=`. Your value is different, because the lab creates it at random.

## Step 3. Read the ended run of the crashing pod

```sh
kubectl -n starfleet get pods -l app=fuse
kubectl -n starfleet logs -l app=fuse -c app --previous
```

The output ends with `fatal: environment variable FUSE_KEY_xxx is not set`. The text after `variable` is the name. Use `--previous` because the current container may be waiting for its next restart and have no log.

## Step 4. Write the ConfigMap

Use the values from steps 1 to 3. This example uses placeholder values:

```sh
kubectl -n starfleet create configmap log-findings \
  --from-literal=audit-code=E417 \
  --from-literal=fuse-key=FUSE_KEY_123 \
  --from-literal=pods=3 \
  --from-literal=containers=api,audit
```

## Step 5. Submit

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-040/module-02/labs/lab-01
```

The reference script `solution/apply.sh` reads the same logs and creates the ConfigMap in one run.
