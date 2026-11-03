# Solution: Inspect A Running Pod And Correct Its Service

## Step 1. Reproduce the failure

```sh
kubectl -n starfleet exec shuttle -- wget -qO- -T 3 http://scout
kubectl -n starfleet get pod scout
kubectl -n starfleet get endpoints scout
```

The request fails. The pod is `Running` and ready, and the Service has an endpoint: the pod IP with port 8080. The Service selects the pod correctly, so the problem is the port.

## Step 2. Read the real port from inside the container

```sh
kubectl -n starfleet exec scout -- netstat -tln
```

The output has a `LISTEN` line for local address `0.0.0.0:9090`. The pod specification declares `containerPort: 8080`, but that field is documentation only. The process listens on 9090.

## Step 3. Read the environment

```sh
kubectl -n starfleet exec scout -- printenv APP_VERSION
```

The command prints `2.4.1`.

## Step 4. Attach the ephemeral container

```sh
kubectl -n starfleet debug scout -c inspector --image=docker.io/library/busybox:1.37.0 --target=app -- sleep 3600
kubectl -n starfleet get pod scout -o jsonpath='{.spec.ephemeralContainers[*].name}{"\n"}'
```

The second command prints `inspector`. The container shares the network namespace of the pod and the process namespace of `app`.

## Step 5. Record the findings

```sh
kubectl -n starfleet create configmap scout-findings \
  --from-literal=listen-port=9090 \
  --from-literal=app-version=2.4.1
```

## Step 6. Correct the Service

The Service is the object that is wrong, not the pod:

```sh
kubectl -n starfleet patch service scout --type=merge \
  -p '{"spec":{"ports":[{"name":"http","port":80,"targetPort":9090}]}}'
kubectl -n starfleet exec shuttle -- wget -qO- -T 3 http://scout
```

The second command now returns the directory listing of the web server. The merge patch replaces the whole `ports` list, so it repeats the name and the port.

## Step 7. Submit

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-050/module-03/labs/lab-01
```

The reference script `solution/apply.sh` does steps 2 to 6 in one run.
