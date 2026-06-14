# Contributing

Thanks for your interest in improving the Kymelio Helm chart catalog. This
document describes the quality standard every chart must meet and the workflow
for adding or changing charts.

## Principles

- Charts are written from scratch. Do not add upstream charts as dependencies
  or wrap them.
- Documentation and comments are in English.
- Keep comments minimal and only where intent is not obvious.

## Adding a new chart

Use the scaffolding generator to create a conformant skeleton:

```sh
scripts/new-chart.sh \
  --name myapp \
  --app-version 1.2.3 \
  --image-repository docker.io/library/myapp \
  --workload deployment \
  --port 8080
```

The generated chart passes `ct lint` out of the box. Fill in the application
specific configuration afterwards.

## Chart quality standard

Every chart must provide:

- `Chart.yaml` with apiVersion v2, name, description, type application, a SemVer
  version starting at 0.1.0, appVersion, home, sources, keywords and maintainers.
- `values.yaml` fully documented with an inline comment per top level key and
  safe defaults.
- `values.schema.json` validating the most important fields.
- `templates/` with a deployment or statefulset, service, serviceaccount,
  configmap or secret where needed, optional ingress (default off), optional hpa
  (default off), optional pdb, optional networkpolicy and an optional
  servicemonitor behind `metrics.serviceMonitor.enabled`.
- `templates/_helpers.tpl` with fullname, labels including the recommended
  `app.kubernetes.io/*` labels, selectorLabels, chart and serviceAccountName.
- `templates/NOTES.txt` with usable post install hints.
- `templates/tests/` with at least one `helm test` connection check.
- Security defaults: podSecurityContext and container securityContext with
  runAsNonRoot, dropped capabilities and a read only root filesystem where
  possible, resource requests and limits, and no `latest` image tags.
- `README.md` with HTTP and OCI installation, a values table compatible with
  helm-docs and upgrade notes.
- StatefulSets ship a persistence block with a configurable storageClass.

## Local validation

Install [chart-testing](https://github.com/helm/chart-testing) and run:

```sh
ct lint --config .github/ct.yaml
helm template charts/<name>
```

To exercise an install against a local cluster:

```sh
kind create cluster
ct install --config .github/ct.yaml
```

## Versioning and commits

- Bump the chart `version` on every change. Use `scripts/bump-version.sh` to do
  this consistently.
- Use Conventional Commits, for example `feat(redis): add sentinel support`.
- Keep commits small and scoped to a single chart or concern. Do not mix
  unrelated charts in one commit.
