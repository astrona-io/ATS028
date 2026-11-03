---
draft: true
exam_objectives:
- Understand API deprecations
---
# Summary

Kubernetes labels each API version as alpha, beta or GA. The deprecation policy gives deprecated GA versions at least 12 months or 3 releases of support and deprecated beta versions at least 9 months or 3 releases. Deprecation is an announcement. Removal is the release in which the API server stops serving the version.

The API server announces a deprecated version with three signals: the `Warning` response header, the `k8s.io/deprecated` audit annotation and the `apiserver_requested_deprecated_apis` metric. A removed version produces an error that contains `no matches for kind`. This error means the group and version are not served, and the stored objects of that resource remain available through a supported version.

Discovery finds what a cluster serves. `kubectl api-versions` and `kubectl api-resources` list served versions and resources, and `kubectl explain --api-version` shows the schema of one version. A server-side dry run and the `--warnings-as-errors` option find unsupported definitions before they change the cluster, and the metric and the audit log find the running clients that still use old versions.

A conversion changes the `apiVersion` and then checks the result. The `kubectl convert` plugin is separate and not installed by default, and a text substitution is enough when the schema of both versions is the same. A converted definition is correct only when the objects it creates behave as before, which a command such as `kubectl auth can-i` can test for permissions.

Key facts:

- Version suffixes: `alpha`, `beta` and no suffix for GA.
- A warning means the request worked. An error means the version is gone.
- Server-side dry run asks the API server. Client-side dry run does not.
- A removed `apiVersion` does not delete the objects of that resource.

<!-- astrona:playground:destroy -->
