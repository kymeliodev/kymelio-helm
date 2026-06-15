# superset

A Helm chart for superset.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-superset kymelio/superset
```

### OCI registry

```sh
helm install my-superset oci://ghcr.io/kymeliodev/kymelio-helm/superset --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-superset
```

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-superset kymelio/superset --reuse-values
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `""` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `8088` | Service port |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| podDisruptionBudget.enabled | bool | `false` | Enable a PodDisruptionBudget |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Run a statsd_exporter sidecar and expose its Prometheus port |
| metrics.image.repository | string | `quay.io/prometheus/statsd-exporter` | Exporter image repository |
| metrics.image.tag | string | `v0.27.1` | Exporter image tag |
| metrics.port | int | `9102` | Exporter Prometheus scrape port |
| metrics.statsdPort | int | `9125` | UDP port the exporter receives StatsD on |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| metrics.serviceMonitor.interval | string | `30s` | Scrape interval |
| metrics.serviceMonitor.scrapeTimeout | string | `10s` | Scrape timeout |
| metrics.serviceMonitor.labels | object | `{}` | Extra labels for the ServiceMonitor |
| extraEnv | list | `[]` | Extra environment variables passed to the container |
| configuration | string | `""` | Inline configuration rendered into a ConfigMap |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot | Pod security context |
| securityContext | object | drop ALL | Container security context |

## Configuration

Superset reads its configuration from a `superset_config.py` file referenced by
the `SUPERSET_CONFIG_PATH` environment variable, and from a small set of
environment variables. Use `configuration` to render a config file into a
ConfigMap and `extraEnv` to point Superset at it and set runtime options.

```yaml
extraEnv:
  - name: SUPERSET_CONFIG_PATH
    value: /config/superset_config.py
  - name: SUPERSET_SECRET_KEY
    valueFrom:
      secretKeyRef:
        name: my-superset
        key: superset-secret-key
configMountPath: /config
configFileName: superset_config.py
configuration: |
  SQLALCHEMY_DATABASE_URI = "postgresql+psycopg2://superset:password@postgresql:5432/superset"
  ROW_LIMIT = 5000
```

### Metrics

Superset does not expose a first class Prometheus HTTP endpoint. It emits
application metrics in StatsD format. Setting `metrics.enabled` runs a
[statsd_exporter](https://github.com/prometheus/statsd_exporter) sidecar that
receives those StatsD samples on UDP port `9125` and republishes them as
Prometheus metrics on port `9102` at `/metrics`. The Service exposes that port
and the ServiceMonitor scrapes it.

Superset itself must be told to send StatsD to the sidecar. Add a stats logger
to `superset_config.py`:

```python
from superset.stats_logger import StatsdStatsLogger
STATS_LOGGER = StatsdStatsLogger(host="127.0.0.1", port=9125, prefix="superset")
```

Then enable the exporter and the ServiceMonitor:

```yaml
metrics:
  enabled: true
  serviceMonitor:
    enabled: true
```

The ServiceMonitor requires the Prometheus Operator CRDs. Without the
`StatsdStatsLogger` snippet the exporter runs but receives no samples.

### Ingress and TLS

Superset serves plain HTTP on port `8088` and expects TLS to be terminated by an
ingress controller or reverse proxy. Enable `ingress` with `ingress.tls` rather
than configuring TLS on the application.
