# Apache Jena Fuseki Docker Images

This repository provides Dockerfiles and automation for building and publishing Apache Jena Fuseki images for multiple versions and platforms.

## Prerequisites

- Docker 24.0 or newer
- The Docker Buildx plugin (ships with Docker Desktop and recent Docker Engine releases)

## Build Locally With Buildx Bake

To test the same build configuration used in CI, run:

```bash
scripts/build-local.sh
```

By default this builds the `fuseki-5-6-0` bake target (version 5.6.0) for `linux/amd64` and loads the image into your local Docker image store under the tags defined in `docker-bake.hcl`.

### Options

- Build a different version: `scripts/build-local.sh 5.5.0`
- Test multiple platforms and push to a registry (requires QEMU emulation): `OUTPUT=push PLATFORM=linux/amd64,linux/arm64 scripts/build-local.sh fuseki-5.6.0`
- Show help: `scripts/build-local.sh --help`

The script ensures a Buildx builder exists, bootstraps it, and mirrors the configuration consumed by the GitHub Actions workflows. Override the `OUTPUT` environment variable with `push` to publish multi-platform images using the same Bake definition.

## Continuous Integration

GitHub Actions workflows in `.github/workflows/` call `docker/bake-action` with the same `docker-bake.hcl` definition to publish multi-platform images on every push. Any changes verified locally with `scripts/build-local.sh` therefore match the pipeline behaviour.
