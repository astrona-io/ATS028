# Solution: Ship A File Log To Standard Output With A Sidecar

## Step 1. Confirm the problem

```sh
kubectl -n starfleet logs deploy/ledger-writer
kubectl -n starfleet exec deploy/ledger-writer -- tail -n 2 /var/log/app/app.log
```

The first command prints nothing. The second prints `ledger-event` lines, so the data exists only in the file inside the container.

## Step 2. Edit the Deployment

```sh
kubectl -n starfleet edit deployment ledger-writer
```

Add a `volumeMounts` list to the `writer` container, a second container and a `volumes` list. The pod spec must contain these parts:

```yaml
      containers:
        - name: writer
          # image and command stay as they are
          volumeMounts:
            - name: logs
              mountPath: /var/log/app
        - name: log-tail
          image: docker.io/library/busybox:1.37.0
          command: ["sh", "-c", "tail -n+1 -F /var/log/app/app.log"]
          volumeMounts:
            - name: logs
              mountPath: /var/log/app
              readOnly: true
      volumes:
        - name: logs
          emptyDir: {}
```

Both containers mount the volume `logs` at the same path. The writer creates the file, and the sidecar reads it. `tail -F` waits when the file does not exist yet.

## Step 3. Wait for the rollout

```sh
kubectl -n starfleet rollout status deployment/ledger-writer
```

The change to the pod template makes the Deployment create a new pod with two containers. The command ends when the new pod is ready.

## Step 4. Read the sidecar log

```sh
kubectl -n starfleet logs deploy/ledger-writer -c log-tail --tail=3
```

The command prints `ledger-event` lines. The `writer` container still prints nothing.

## Step 5. Submit

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-040/module-03/labs/lab-01
```

The reference solution is the manifest `solution/ledger-writer.yaml`, which `solution/apply.sh` applies.
