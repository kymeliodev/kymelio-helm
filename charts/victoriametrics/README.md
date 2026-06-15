# victoriametrics

Fast and cost effective time series database, deployed as a single node
StatefulSet with persistent storage. It ingests Prometheus style metrics and
serves PromQL and MetricsQL queries over HTTP.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-victoriametrics kymelio/victoriametrics
```

### OCI registry

```sh
helm install my-victoriametrics oci://ghcr.io/kymeliodev/kymelio-helm/victoriametrics --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-victoriametrics
```

The PersistentVolumeClaim is retained after uninstall. Delete it manually to
discard the stored metrics.

## Upgrading

Review the chart version change and your overridden values before upgrading.

```sh
helm upgrade my-victoriametrics kymelio/victoriametrics --reuse-values
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas, single node deployment |
| image.repository | string | `docker.io/victoriametrics/victoria-metrics` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| args | list | storageDataPath and httpListenAddr | Command line flags for the binary |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `8428` | HTTP service port |
| service.portName | string | `http` | Named service port |
| persistence.enabled | bool | `true` | Enable a PersistentVolumeClaim |
| persistence.storageClass | string | `""` | StorageClass, empty uses the cluster default |
| persistence.size | string | `8Gi` | Size of the data volume |
| persistence.mountPath | string | `/victoria-metrics-data` | Data directory mount path |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Publish a dedicated metrics Service port for the Prometheus endpoint |
| metrics.port | int | `8428` | Port published on the Service for the metrics endpoint |
| metrics.path | string | `/metrics` | HTTP path where VictoriaMetrics exposes metrics |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor (requires metrics.enabled) |
| metrics.serviceMonitor.interval | string | `30s` | Scrape interval for the ServiceMonitor |
| metrics.serviceMonitor.scrapeTimeout | string | `10s` | Scrape timeout for the ServiceMonitor |
| metrics.serviceMonitor.labels | object | `{}` | Extra labels added to the ServiceMonitor |
| tls.enabled | bool | `false` | Serve HTTPS on the http listener |
| tls.existingSecret | string | `""` | Secret holding the certificate and key |
| extraArgs | list | `[]` | Extra flags appended to the binary entrypoint |

## Configuration

### Prometheus metrics

VictoriaMetrics exposes Prometheus metrics at `/metrics` on its http listener
(port `8428`). Set `metrics.enabled` to publish a dedicated `metrics` Service
port and create a `ServiceMonitor` for the Prometheus Operator:

```yaml
metrics:
  enabled: true
  serviceMonitor:
    enabled: true
    interval: 30s
    scrapeTimeout: 10s
    labels:
      release: kube-prometheus-stack
```

If you do not run the Prometheus Operator, leave `serviceMonitor.enabled` at
`false` and scrape the Service directly:

```
release-name-victoriametrics.<namespace>.svc.cluster.local:8428/metrics
```

### Server tuning

VictoriaMetrics is configured through command line flags. Override the defaults
with `args`, or append extra flags with `extraArgs`. For example, to set a
retention period and raise the in memory cache:

```yaml
extraArgs:
  - --retentionPeriod=12
  - --memory.allowedPercent=70
```

### TLS

When `tls.enabled` is true, VictoriaMetrics serves HTTPS on the http listener
using the certificate and key from an existing Secret:

```yaml
tls:
  enabled: true
  existingSecret: victoriametrics-tls
  certFilename: tls.crt
  keyFilename: tls.key
```
