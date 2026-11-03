---
draft: true
exam_objectives:
- Use built-in CLI tools to monitor Kubernetes applications
---
# Output Formats, Sorting And Resource Usage

The API server returns each object as a full document. `kubectl` then renders it. The default rendering is a table with a few columns chosen by the server. The flag `-o` (long form `--output`) selects another rendering. Choosing the right one turns a long listing into the single value or the short table that answers the question.

## The output formats

| Format | What it prints |
| --- | --- |
| (none) | Server-side table with default columns |
| `-o wide` | The default table plus extra columns, such as node and pod IP |
| `-o name` | One `kind/name` line per object |
| `-o yaml`, `-o json` | The complete objects |
| `-o jsonpath=...` | Values selected by a JSONPath expression |
| `-o custom-columns=...` | A table with columns you define |
| `-o go-template=...` | Output rendered by a Go template |

Open the playground and compare the first three:

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet get pods
kubectl -n starfleet get pods -o wide
kubectl -n starfleet get pods -o name
```

`-o wide` adds `IP`, `NODE`, `NOMINATED NODE` and `READINESS GATES`. `-o name` prints `pod/probe-...`, which is the form other commands and shell loops accept.

## JSONPath

JSONPath selects parts of the JSON document of the object. The expression is placed in braces. `$` is the root and is optional in `kubectl`. For a list command the root is an object with an `items` array.

```sh
kubectl -n starfleet get pod shuttle -o jsonpath='{.status.podIP}{"\n"}'
kubectl -n starfleet get pods -o jsonpath='{.items[*].metadata.name}{"\n"}'
kubectl -n starfleet get pods -o jsonpath='{.items[0].spec.containers[0].image}{"\n"}'
```

The first prints one IP address. The second prints all names on one line separated by spaces. The third prints the first container image of the first pod. Text outside braces is copied as it is, so `{"\n"}` adds a newline.

To print one line per object, use `range`:

```sh
kubectl -n starfleet get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.phase}{"\n"}{end}'
```

A filter expression selects array entries by a condition. This prints the type of the condition that is `True` for one pod:

```sh
kubectl -n starfleet get pod shuttle -o jsonpath='{.status.conditions[?(@.status=="True")].type}{"\n"}'
```

When a key contains a dot, escape it. The label `kubernetes.io/name` is written `{.metadata.labels.kubernetes\.io/name}`.

If a path matches nothing, JSONPath prints an empty string, not an error. An empty result can mean a wrong path. Check the path against `-o json` first.

## Custom columns

`custom-columns` prints a table. Each column is `HEADER:JSONPATH`, with the path relative to one object:

```sh
kubectl -n starfleet get pods -o custom-columns='NAME:.metadata.name,NODE:.spec.nodeName,PHASE:.status.phase,IMAGE:.spec.containers[0].image'
```

Use `custom-columns-file=columns.txt` when the definition is long. The file has a header line and a path line, and the columns line up by position.

## Sorting

`--sort-by` takes a JSONPath expression that points at a field in each item, and sorts the list ascending by that field. It does not need `.items`.

```sh
kubectl -n starfleet get pods --sort-by=.metadata.creationTimestamp
kubectl -n starfleet get pods --sort-by=.status.startTime
kubectl -n starfleet get pods --sort-by=.metadata.name
```

The newest pod is the last line. For descending order, pipe to `tac` or `sort -r`, or read the last line with `tail -n1`. Sorting happens in `kubectl`, after the list has been received. Timestamps have a resolution of one second, so objects created in the same second keep an arbitrary order.

## Resource usage with kubectl top

`kubectl top` shows current CPU and memory use. It does not read the container runtime directly. It asks the Metrics API, `metrics.k8s.io`, which is served by metrics-server. Metrics-server is an add-on that scrapes the kubelet on every node about once a minute and keeps only the latest sample in memory. The playground enables it.

```sh
kubectl top nodes
kubectl top pods -n starfleet
kubectl top pods -n starfleet --containers
kubectl top pods -n starfleet --sort-by=memory
```

CPU is shown in millicores: `250m` is a quarter of one core. Memory is shown in mebibytes (`Mi`). If metrics-server has no sample yet, the command prints `error: Metrics API not available` or `metrics not available yet`. Wait a minute and try again. The available sort keys for `top` are `cpu` and `memory`.

Check that the Metrics API is registered:

```sh
kubectl get apiservice v1beta1.metrics.k8s.io
```

The `AVAILABLE` column must read `True`. If it reads `False (MissingEndpoints)` or the object does not exist, metrics-server is not running, and no `kubectl top` command can work.

## Usage is not allocation

`kubectl top` reports what the container uses now. The values `requests` and `limits` in the pod spec are what the scheduler reserves and what the kernel enforces. They are different numbers. Compare them with custom columns:

```sh
kubectl -n starfleet get pods -o custom-columns='NAME:.metadata.name,CPU_REQ:.spec.containers[0].resources.requests.cpu,MEM_LIMIT:.spec.containers[0].resources.limits.memory'
```

A pod can use far less than it requests, and the scheduler still counts the full request against the node.

## Common pitfalls

> [!WARNING]
> - **Reading an empty JSONPath result as "no data".** A wrong path prints nothing. Compare with `-o json`.
> - **Forgetting `.items` in `jsonpath` on lists.** `--sort-by` does not use it; `-o jsonpath` does.
> - **Using `top` right after cluster start.** The first sample needs up to a minute.
> - **Treating `top` as history.** It is one recent sample, not a time series.
> - **Comparing `top` with requests as if they were one number.** One is use, the other is a reservation.
