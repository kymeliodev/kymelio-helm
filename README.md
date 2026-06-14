# Kymelio Helm Charts

A curated catalog of production grade Helm charts for popular cloud native
applications. Every chart in this repository is written from scratch as a clean,
standalone implementation. No upstream charts are wrapped or pulled in as
dependencies.

Charts are published two ways in parallel:

- A classic HTTP Helm repository served from GitHub Pages.
- OCI artifacts in the GitHub Container Registry.

## Usage

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm search repo kymelio
```

Install a chart, for example PostgreSQL:

```sh
helm install my-postgresql kymelio/postgresql
```

### OCI registry

```sh
helm install my-postgresql oci://ghcr.io/kymeliodev/kymelio-helm/postgresql --version 0.1.1
```

You can pull or template charts directly from the registry as well:

```sh
helm pull oci://ghcr.io/kymeliodev/kymelio-helm/postgresql --version 0.1.1
```

## Catalog

The full, browsable catalog lives at
[https://kymeliodev.github.io/kymelio-helm](https://kymeliodev.github.io/kymelio-helm).

## Repository layout

```
charts/        one directory per chart
docs/          catalog landing page for GitHub Pages
scripts/       chart scaffolding and maintenance helpers
.github/       chart-testing config and CI workflows
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for the chart quality standard, the
scaffolding generator, and the local validation workflow.

## License

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE).
