# Solution: Migrate Ingress, CronJob, HorizontalPodAutoscaler And PodDisruptionBudget

## Step 1. Read the legacy definitions

```sh
kubectl -n starfleet get configmap legacy-manifests -o jsonpath='{.data.ingress\.yaml}'
kubectl -n starfleet get configmap legacy-manifests -o jsonpath='{.data.cronjob\.yaml}'
kubectl -n starfleet get configmap legacy-manifests -o jsonpath='{.data.hpa\.yaml}'
kubectl -n starfleet get configmap legacy-manifests -o jsonpath='{.data.pdb\.yaml}'
```

Each file names an old version: `extensions/v1beta1`, `batch/v1beta1`, `autoscaling/v2beta1` and `policy/v1beta1`. The cluster does not serve them, so applying the files fails.

## Step 2. Confirm the supported versions

```sh
kubectl api-resources --api-group=networking.k8s.io
kubectl api-resources --api-group=autoscaling
kubectl explain ingress.spec.rules.http.paths.backend.service
```

The Ingress is served by `networking.k8s.io/v1`, the HorizontalPodAutoscaler by `autoscaling/v2`, the CronJob by `batch/v1` and the PodDisruptionBudget by `policy/v1`.

## Step 3. Change the Ingress

Three things change in the Ingress: the backend uses `service.name` and `service.port.number`, the path has a `pathType`, and the class annotation becomes `spec.ingressClassName`:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: probe-edge
  namespace: starfleet
spec:
  ingressClassName: nginx
  rules:
  - host: edge.starfleet.example
    http:
      paths:
      - path: /status
        pathType: Prefix
        backend:
          service:
            name: probe
            port:
              number: 80
```

## Step 4. Change the other three definitions

The CronJob only needs `apiVersion: batch/v1`, and the PodDisruptionBudget only needs `apiVersion: policy/v1`. The HorizontalPodAutoscaler needs `apiVersion: autoscaling/v2` and a new target:

```yaml
metrics:
- type: Resource
  resource:
    name: cpu
    target:
      type: Utilization
      averageUtilization: 55
```

## Step 5. Apply and check

Save the four definitions in one file and apply it:

```sh
kubectl apply -f migrated.yaml
kubectl -n starfleet get ingress,cronjob,hpa,pdb
kubectl -n starfleet exec shuttle -- wget -qO- -T 3 http://probe/
```

The last command still returns the response of the probe application, which shows that the migration did not touch the workload.

## Step 6. Submit

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-010/module-03/labs/lab-01
```

The reference file is `solution/solution.yaml`, which `solution/apply.sh` applies.
