# Multi-Container And Multi-Pod Logs - Playground

- **Slug:** ats-028-playground-040-02
- **Type:** Astrona playground: clean environment, no task, no grading
- **Status:** UNTESTED - authored without starting the environment

A single-node kind cluster (Kubernetes 1.35) with the example workloads described in [docs/overview.md](docs/overview.md). Nothing to submit.

## Run it

```sh
astrona run -c .
astrona destroy ats-028-playground-040-02
```

`astrona destroy` takes the environment name, not the config path. `astrona submit` and `astrona test` do not apply because nothing is graded.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition: runtime, preloaded images, starting manifests |
| `manifests/` | Namespaces and workloads applied at start |
| `docs/overview.md` | What the environment contains and ideas to try |
