# Solution: Migrate An Old Release To The Supported APIs

## Step 1. Read the legacy files

```sh
kubectl -n outpost get configmap legacy-bundle -o jsonpath='{.data.deployment\.yaml}'
```

Repeat the command for `cronjob.yaml`, `pdb.yaml` and `hpa.yaml`. Each file names an API version that the cluster no longer serves, so `kubectl apply` on the old text is rejected.

## Step 2. Find the served versions

```sh
kubectl api-resources --api-group=apps
kubectl api-resources --api-group=batch
kubectl api-resources --api-group=policy
kubectl api-resources --api-group=autoscaling
kubectl api-versions
```

The first four commands list the kinds of each group with their served version. `kubectl api-versions` lists every `group/version`. The Deployment is served by `apps/v1`, the CronJob by `batch/v1`, the PodDisruptionBudget by `policy/v1` and the HorizontalPodAutoscaler by `autoscaling/v2`.

## Step 3. Write the supported Deployment

Save the manifest as `relay.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: relay
  namespace: outpost
spec:
  replicas: 2
  selector:
    matchLabels:
      app: relay
  template:
    metadata:
      labels:
        app: relay
    spec:
      containers:
        - name: relay
          image: docker.io/library/python:3.13-alpine
          command: ["python", "/app/server.py"]
          ports:
            - name: http
              containerPort: 8080
          readinessProbe:
            httpGet:
              path: /ready
              port: http
            periodSeconds: 2
          volumeMounts:
            - name: app
              mountPath: /app
              readOnly: true
      volumes:
        - name: app
          configMap:
            name: probe-code
```

The `spec.selector` field is the change: the old version filled it from the template labels, and `apps/v1` requires it. Apply it with `kubectl apply -f relay.yaml`.

## Step 4. Change the other three versions

Change the first line of the CronJob to `apiVersion: batch/v1`, of the PodDisruptionBudget to `apiVersion: policy/v1` and of the HorizontalPodAutoscaler to `apiVersion: autoscaling/v2`. Keep every other field. The metric block of the HorizontalPodAutoscaler already has the `target` form that `autoscaling/v2` uses. Apply each file with `kubectl apply -f`.

## Step 5. Record the versions

```sh
kubectl -n outpost create configmap api-audit \
  --from-literal=deployment=apps/v1 \
  --from-literal=cronjob=batch/v1 \
  --from-literal=pdb=policy/v1 \
  --from-literal=hpa=autoscaling/v2
```

## Step 6. Wait and test the Service

```sh
kubectl -n outpost rollout status deployment/relay
kubectl -n outpost exec drifter -- wget -q -T 3 -O- http://relay/
```

The second command prints a line that starts with `version=v1`.

## Step 7. Submit

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-010/capstone/labs/lab-01
```

`solution/apply.sh` applies the same objects with one command.
