# Solution: Debug A Release With Three Problems

## Step 1. Read the status

```sh
kubectl -n starfleet get pods
kubectl -n starfleet get endpoints hail
```

The pods of `hail` are `Running` but `0/1` ready, and the endpoints are empty. The pod of `dock` shows `ErrImagePull` or `ImagePullBackOff`.

## Step 2. Confirm the causes

```sh
kubectl -n starfleet describe pod -l app=hail
kubectl -n starfleet describe pod -l app=dock
kubectl -n starfleet get deployment hail -o jsonpath='{.spec.template.spec.containers[0].ports}{"\n"}{.spec.template.spec.containers[0].readinessProbe}{"\n"}'
```

The events of `hail` show `Unhealthy` with a readiness probe failure, a connection refused on port 8081. The container port is named `http` and is 8080, so the probe targets a port where nothing listens. The events of `dock` show a failed pull of the tag `1.37.99`.

## Step 3. Read the facts from inside `beacon`

```sh
kubectl -n starfleet exec beacon -- printenv BUILD_ID
kubectl -n starfleet exec beacon -- netstat -tln
```

The first command prints `b-7731`. The second shows a `LISTEN` line for port 9191.

## Step 4. Record the findings

```sh
kubectl -n starfleet create configmap capstone-report \
  --from-literal=hail=Unhealthy \
  --from-literal=dock=ImagePullBackOff \
  --from-literal=beacon-build=b-7731 \
  --from-literal=beacon-port=9191
```

## Step 5. Attach the ephemeral container

```sh
kubectl -n starfleet debug beacon -c inspector --image=docker.io/library/busybox:1.37.0 --target=app -- sleep 3600
```

## Step 6. Repair the Deployments

```sh
kubectl -n starfleet patch deployment hail --type=json \
  -p '[{"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/port","value":"http"}]'
kubectl -n starfleet set image deployment/dock main=docker.io/library/busybox:1.37.0
kubectl -n starfleet rollout status deployment/hail
kubectl -n starfleet exec shuttle -- wget -qO- -T 3 http://hail
```

The probe keeps its path and gets the named port, so it checks the port the application serves. The request returns the application response.

## Step 7. Submit

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-050/capstone/labs/lab-01
```

The reference script `solution/apply.sh` does steps 3 to 6 in one run.
