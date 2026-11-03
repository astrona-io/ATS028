---
draft: true
exam_objectives:
- Utilize container logs
---
# Limiting, Timing And Following Logs

A container that runs for days can print millions of lines. A command that prints all of them is slow and hides the one line you need. `kubectl logs` has options that limit the output by line count and by time, add timestamps, and keep the stream open. A selector adds a second problem: many pods share one command, and `kubectl` applies its own defaults and limits. This part shows each option on the `multi` and `flaky` Deployments.

## Limit by line count

The flag `--tail=N` prints the last `N` lines of the log. The value `-1` means all lines. For a single pod the default is all lines. For a selector the default changes:

```sh
kubectl -n starfleet logs -l app=multi -c worker --prefix
```

Each of the three pods contributes only its last 10 lines, although each has printed more. When you give `-l` and no `--tail`, `kubectl` uses 10 per pod. This is the second reason a selector command shows only some of the log. To read everything, ask for it:

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet logs -l app=multi -c worker --prefix --tail=-1
```

Without `--follow`, `kubectl` reads the pods one after another, so the output is grouped by pod. The related flag `--limit-bytes=N` stops after `N` bytes, which protects your terminal from a very large log.

## Limit by time

The flag `--since` takes a duration such as `30s`, `5m` or `2h` and prints only lines newer than that. The flag `--since-time` takes a timestamp in RFC 3339 format, for example `2026-11-03T10:00:00Z`. Use only one of the two.

```sh
kubectl -n starfleet logs deploy/multi -c web --since=20s
```

At one line every two seconds, the command prints about ten lines. The container runtime stores a timestamp with each line in the log file, and the kubelet filters on it. The application does not need to print a time itself.

## Show timestamps

The flag `--timestamps` adds that stored time to the start of each line, in RFC 3339 format with nanoseconds:

```sh
kubectl -n starfleet logs deploy/multi -c worker --timestamps --tail=5
```

The timestamp is the time the runtime received the line, which is the time you want when you compare a log with an incident. It is not the time inside the application's own message. Timestamps also let you merge several pods into one ordered view. With `--prefix` each line starts with the pod tag, so the timestamp is the second field and `sort -k2` orders by time:

```sh
kubectl -n starfleet logs -l app=multi -c worker --prefix --timestamps --tail=4 | sort -k2
```

## Filter with grep

`kubectl` has no option that filters by text. Pipe the output to `grep`, and ask for the whole log first, because a `--tail` limit applies before `grep`:

```sh
kubectl -n starfleet logs -l app=multi -c worker --prefix --tail=-1 | grep ERROR
```

Each `worker` container prints a `worker ERROR job=N retry=1` line on every fifth job, so one line per five jobs appears for each pod. The prefix tells you which pod reported it.

## Follow a log

The flag `-f` (long form `--follow`) keeps the request open, and the kubelet sends new lines as the container writes them. Stop it with Ctrl+C:

```sh
kubectl -n starfleet logs deploy/multi -c web -f --tail=2
```

A followed stream is a long-lived connection through the API server to the kubelet. If the connection breaks, the command ends and you start it again. Silence in a followed log means only that nothing new was written. It does not prove the process is healthy.

## Follow many streams and --max-log-requests

Following a selector opens one stream for each container of each pod, and `kubectl` limits the number of streams at once. The default limit is 5. The `multi` Deployment has three pods with two containers, which is six streams:

```sh
kubectl -n starfleet logs -l app=multi --all-containers --prefix -f
```

The command fails at once with an error that names the number of streams and the limit, and that points to `--max-log-requests`. Raise the limit to the number you need, or narrow the selection with `-c`:

```sh
kubectl -n starfleet logs -l app=multi --all-containers --prefix -f --max-log-requests=6 --tail=1
```

The limit exists because each stream holds a connection to a kubelet. Without `-f`, the limit does not apply.

## Read the previous run of a crashing container

The `flaky` container exits with code 1 on every start, so the kubelet restarts it with an increasing delay. While it waits, the current container may have no log yet. Read the run that already ended with `--previous` (short form `-p`):

```sh
kubectl -n starfleet get pods -l app=flaky
kubectl -n starfleet logs deploy/flaky --previous
```

The command prints `boot step=1 starting` and the line `fatal: cannot open /etc/flaky/config.yaml`. The second line was written to standard error, and `kubectl logs` shows standard output and standard error together. The kubelet keeps the log of the last ended run of each container. It does not keep older runs, and it removes them when the pod is deleted.

This part covered the options that shape one log request: how many lines, which time window, whether to follow and how to read an ended run. The remaining gap is a log that the node no longer holds, because of rotation or because the pod is gone. Collecting logs beyond the node is a separate question about logging architecture.

## Common pitfalls

> [!WARNING]
> - **Expecting the whole log from a selector.** Without `--tail`, each pod gives 10 lines.
> - **Combining `--since` and `--since-time`.** Use one of them.
> - **Reading `--timestamps` as application time.** It is the time the runtime stored the line.
> - **Using `grep` after a small `--tail`.** The line you want may already be cut off. Use `--tail=-1`.
> - **Following a selector with more than 5 streams.** The command fails until you add `--max-log-requests`.
> - **Reading the current log of a crash loop.** The message is in `--previous`.
