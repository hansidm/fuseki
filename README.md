# Apache Jena Fuseki Docker Images

This repository provides Dockerfiles and automation for building and publishing Apache Jena Fuseki images for multiple versions and platforms.

The images start Fuseki from a shared assembler config at `/usr/local/fuseki/run/config.ttl`. That config enables Lucene-backed full-text search by wrapping a TDB2 dataset in a Jena `text:TextDataset`.

## Prerequisites

- Docker 24.0 or newer
- The Docker Buildx plugin (ships with Docker Desktop and recent Docker Engine releases)

## Build Locally With Buildx Bake

To test the same build configuration used in CI, run:

```bash
scripts/build-local.sh
```

By default this builds the `fuseki-6-0-0` bake target (version 6.0.0) for `linux/amd64` and loads the image into your local Docker image store under the tags defined in `docker-bake.hcl`.

### Options

- Build a different version: `scripts/build-local.sh 5.5.0`
- Test multiple platforms and push to a registry (requires QEMU emulation): `OUTPUT=push PLATFORM=linux/amd64,linux/arm64 scripts/build-local.sh fuseki-5.6.0`
- Show help: `scripts/build-local.sh --help`

The script ensures a Buildx builder exists, bootstraps it, and mirrors the configuration consumed by the GitHub Actions workflows. Override the `OUTPUT` environment variable with `push` to publish multi-platform images using the same Bake definition.

## Full-Text Search

The images now expose a text-enabled dataset at `/ds` with the following on-disk layout:

- `/ds/tdb2` for the RDF store
- `/ds/lucene` for the Lucene index

The default configuration indexes `rdfs:label` into the `label` text field. Data written through Fuseki updates the Lucene index automatically.

Example query:

```sparql
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX text: <http://jena.apache.org/text#>

SELECT ?s ?score
WHERE {
  (?s ?score) text:query (rdfs:label "alice")
}
ORDER BY DESC(?score)
```

If you preload or restore the TDB2 store outside Fuseki, rebuild the Lucene index with:

```bash
java -cp /usr/local/fuseki/fuseki-server.jar jena.textindexer \
  --desc=/usr/local/fuseki/run/config.ttl
```

To index different predicates or analyzers, edit `config.ttl` before building. The key section is the `text:map` block in the shared assembler file.

## Continuous Integration

GitHub Actions workflows in `.github/workflows/` call `docker/bake-action` with the same `docker-bake.hcl` definition to publish multi-platform images on every push. Any changes verified locally with `scripts/build-local.sh` therefore match the pipeline behaviour.
