---
draft: true
exam_objectives:
- Understand API deprecations
---
# Finding Deprecated API Use And Converting Definitions

An upgrade plan needs a list of every manifest and client that uses a deprecated or removed API version. The list comes from the cluster itself and from the manifests in the repository. This part shows the discovery commands, the metric that counts deprecated requests, and a safe way to change a definition and prove that it still means the same thing.

## Ask the cluster what it serves

The API server publishes the groups, versions and resources it serves. This is called API discovery. Two kubectl commands read it.

`kubectl api-versions` prints every served `group/version`. `kubectl api-resources` prints every served resource with its short name, its API group, whether it lives inside a namespace and its `kind`. Together they answer the first question about any old manifest: is the version in its `apiVersion` line served?

<!-- astrona:playground:renew -->

```sh
kubectl api-versions | grep -E 'rbac|scheduling'
kubectl api-resources --api-group=rbac.authorization.k8s.io
```

The first command lists `rbac.authorization.k8s.io/v1` and `scheduling.k8s.io/v1` and no `v1beta1` entry for either group. The second command lists the RBAC (role-based access control) resources: `roles`, `rolebindings`, `clusterroles` and `clusterrolebindings`. A Role is a set of permissions inside one namespace, and a RoleBinding gives those permissions to a user, group or service account.

Discovery shows names, not fields. To see the fields of the supported version, ask for its schema:

```sh
kubectl explain role.rules --api-version=rbac.authorization.k8s.io/v1
```

The `--api-version` flag selects the version to describe, so the same command works for a resource that exists in more than one version. The output lists the fields of a rule: `apiGroups`, `resources` and `verbs`.

## Check a definition before it changes anything

The playground holds a Role and a RoleBinding written for `rbac.authorization.k8s.io/v1beta1`, a version that was removed in Kubernetes v1.22. Extract the Role from the ConfigMap and ask the API server to validate it:

```sh
kubectl -n starfleet get configmap legacy-manifests -o jsonpath='{.data.role\.yaml}' > role.yaml
kubectl apply --dry-run=server -f role.yaml
```

A server-side dry run runs the full admission and validation path in the API server but does not store the object. It fails here with a `no matches for kind "Role"` error, the same removal error the Ingress produced. A client-side dry run (`--dry-run=client`) would not catch this problem, because kubectl alone cannot know which versions the server serves.

Two kubectl options turn warnings into something a pipeline can act on. `--warnings-as-errors` makes any command that receives a `Warning` header exit with a non-zero status. Run it in a continuous integration job and the job fails when a manifest uses a deprecated version, before the version is removed.

## Count deprecated requests with the metric

Manifests in a repository are one source of old API use. The other source is software already running in the cluster: controllers, operators and scripts that send requests on their own. The metric `apiserver_requested_deprecated_apis` finds them. The API server exposes its metrics at the `/metrics` path, and kubectl can read any API path with `get --raw`:

```sh
kubectl get --raw /metrics | grep apiserver_requested_deprecated_apis
```

Each line has the labels `group`, `version`, `resource`, `subresource` and `removed_release`, and the value is `1`. The value is a marker and not a request count: the metric says that a deprecated version was requested since the API server started, and `removed_release` says in which Kubernetes release it disappears. The playground cluster has had few clients, so expect a line only if a request to a deprecated version was made since it started, and no line from a controller. A production cluster usually shows more lines, and a pair such as `batch` `v1beta1` `cronjobs` points at software that must change before the upgrade.

The metric shows that a client exists but not which one. To find the caller, search the audit log for the annotation `k8s.io/deprecated: "true"`. The audit event contains the user name and user agent of the client that sent the request.

## Convert the definition

Changing a definition has two steps: change the version, then check the result. For Role and RoleBinding the schema of `v1` is the same as `v1beta1`, so the version string is the only change. A text substitution produces a new file and keeps the original:

```sh
sed 's#rbac.authorization.k8s.io/v1beta1#rbac.authorization.k8s.io/v1#' role.yaml > role-v1.yaml
grep apiVersion role-v1.yaml
```

The `#` characters are the delimiter of the substitution, so the slashes in the version do not need escaping. The `grep` line shows the new `apiVersion` and confirms that the command changed only that line.

kubectl can also convert definitions with a plugin, `kubectl convert`. The plugin is a separate download and is not installed by default, so check with `kubectl convert --help` before a procedure depends on it. When it is present, `kubectl convert -f role.yaml --output-version rbac.authorization.k8s.io/v1` writes the converted definition to standard output. Read its result before applying it, because a converter can add default fields that the original file did not contain.

Apply the new file with warnings treated as errors, so a leftover deprecated version stops the command:

```sh
kubectl apply --warnings-as-errors -f role-v1.yaml
```

Do the same for the RoleBinding, which lives under the key `rolebinding.yaml` in the ConfigMap. Extract it, replace the version with the same `sed` pattern, and apply the result.

## Prove that the meaning did not change

A manifest that the API server accepts is not proof that it grants the same permissions. Ask the cluster what the service account can do. `kubectl auth can-i` asks the authorization system, and `--as` makes the question about another identity:

```sh
kubectl auth can-i list pods -n starfleet --as=system:serviceaccount:starfleet:shuttle-reader
kubectl auth can-i delete pods -n starfleet --as=system:serviceaccount:starfleet:shuttle-reader
```

The first command prints `yes` because the Role allows `get` and `list` on pods. The second prints `no` because nothing allows `delete`. A migration that kept the version change small should give exactly the answers the old definition gave. If an answer changes, the converted file differs from the original in more than the version.

You can now find old API use in manifests and in running clients, change a definition without losing its meaning, and check the result against live behavior. Some resources change shape between versions, and for those the version string is only the start of the work.

## Common pitfalls

> [!WARNING]
> - `--dry-run=client` does not contact the API server, so it cannot find a removed version. Use `--dry-run=server`.
> - The metric `apiserver_requested_deprecated_apis` resets when the API server restarts. An empty result on a freshly restarted cluster does not prove that no client uses an old version.
> - Never apply the output of `kubectl convert` without reading it. Check that the selectors, names and permissions match the original.
> - `kubectl api-versions` lists what the cluster serves now. A manifest for a different cluster version needs the discovery output of that cluster.
