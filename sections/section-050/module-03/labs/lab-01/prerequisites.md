# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl` and `jq` on your machine.
- Network access, so the cluster can pull the container images.

The lab starts a single-node kind cluster (Kubernetes 1.35). `kubectl` points at it after `astrona run`. The commands for the lab are in the README of this folder.
