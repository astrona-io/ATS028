# Solution: Read Container Logs And Add A Log Sidecar

## Step 1. Find the audit error code

```sh
kubectl -n starfleet get pods -l app=manifest
kubectl -n starfleet logs deploy/manifest -c audit --tail=60 | grep 'ERROR code='
```

The pods have two containers, so the `-c audit` flag is required. The command prints lines that contain `ERROR code=` and a code that starts with `E`. All lines show the same code. Note the code.

## Step 2. Find the variable that the valve is missing

```sh
kubectl -n starfleet get pods -l app=valve
kubectl -n starfleet logs -l app=valve -c app --previous
```

The container stops after it prints a message, so the pod restarts. `--previous` prints the log of the run that ended. The message starts with `fatal: environment variable` and names a variable that starts with `VALVE_KEY_`. Note the name.

## Step 3. Count the pods and list the containers

```sh
kubectl -n starfleet get pods -l app=manifest --no-headers | wc -l
kubectl -n starfleet get deployment manifest -o jsonpath='{range .spec.template.spec.containers[*]}{.name}{"\n"}{end}' | sort | paste -sd, -
```

The first command prints 3. The second prints the two container names sorted by name and joined with a comma.

## Step 4. Create the report

```sh
kubectl -n starfleet create configmap log-report \
  --from-literal=audit-code=<code from step 1> \
  --from-literal=valve-key=<name from step 2> \
  --from-literal=pods=3 \
  --from-literal=containers=<names from step 3>
```

Replace each placeholder with the value that you noted.

## Step 5. Add the sidecar to gauge

```sh
kubectl -n starfleet edit deployment gauge
```

The pod spec must contain these parts, and the `writer` image and command stay as they are:

```yaml
      containers:
        - name: writer
          # image and command stay as they are
          volumeMounts:
            - name: gauge-logs
              mountPath: /var/log/gauge
        - name: log-tail
          image: docker.io/library/busybox:1.37.0
          command: ["sh", "-c", "tail -n+1 -F /var/log/gauge/gauge.log"]
          volumeMounts:
            - name: gauge-logs
              mountPath: /var/log/gauge
              readOnly: true
      volumes:
        - name: gauge-logs
          emptyDir: {}
```

Both containers mount the same volume. The writer creates the file, and the sidecar reads it. `tail -F` waits when the file does not exist yet.

## Step 6. Wait and read the sidecar log

```sh
kubectl -n starfleet rollout status deployment/gauge
kubectl -n starfleet logs deploy/gauge -c log-tail --tail=3
```

The change to the pod template makes the Deployment create a new pod with two containers. The second command prints `gauge-reading` lines.

## Step 7. Submit

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-040/capstone/labs/lab-01
```

`solution/apply.sh` applies the same steps with commands.
