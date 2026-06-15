# vector

High performance observability data pipeline, deployed as a single Deployment.
The bundled pipeline reads from a demo_logs source and writes to a console sink,
while the GraphQL API is enabled on the api port for health checks and live
inspection. Replace `config` to point Vector at your own sources and sinks.

The Vector configuration is rendered from `config` into a ConfigMap and mounted
at `configMountPath` via subPath. A `checksum/config` annotation rolls the pods
when the configuration changes.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-vector kymelio/vector
```

### OCI registry

```sh
helm install my-vector oci://ghcr.io/kymeliodev/kymelio-helm/vector --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-vector
```

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-vector kymelio/vector --reuse-values
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `docker.io/timberio/vector` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| args | list | config flag | Command line flags for the Vector binary |
| config | object | demo_logs to console | Vector configuration rendered into a ConfigMap |
| configMountPath | string | `/etc/vector/vector.yaml` | Mount path of the configuration file |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `8686` | GraphQL API port |
| service.portName | string | `api` | Named service port |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Publish a dedicated metrics Service port for the prometheus_exporter sink |
| metrics.port | int | `9598` | Port published on the Service and container for the metrics endpoint |
| metrics.path | string | `/metrics` | HTTP path served by the prometheus_exporter sink |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor (requires metrics.enabled) |
| metrics.serviceMonitor.interval | string | `30s` | Scrape interval for the ServiceMonitor |
| metrics.serviceMonitor.scrapeTimeout | string | `10s` | Scrape timeout for the ServiceMonitor |
| metrics.serviceMonitor.labels | object | `{}` | Extra labels added to the ServiceMonitor |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |

## Configuration

### Prometheus metrics

Vector publishes its internal metrics through a `prometheus_exporter` sink. The
sink is not part of the default pipeline, so enabling metrics requires two
changes: set `metrics.enabled` to publish the `metrics` Service and container
port (`9598`), and add an `internal_metrics` source feeding a
`prometheus_exporter` sink that listens on `0.0.0.0:9598` in the Vector config:

```yaml
metrics:
  enabled: true
  serviceMonitor:
    enabled: true
    interval: 30s
    scrapeTimeout: 10s
    labels:
      release: kube-prometheus-stack

config:
  vector.yaml: |
    api:
      enabled: true
      address: 0.0.0.0:8686
    sources:
      demo:
        type: demo_logs
        format: json
        interval: 1.0
      internal:
        type: internal_metrics
    sinks:
      console:
        type: console
        inputs:
          - demo
        encoding:
          codec: json
      prometheus:
        type: prometheus_exporter
        inputs:
          - internal
        address: 0.0.0.0:9598
```

The `prometheus_exporter` sink serves metrics at `/metrics`. If you do not run
the Prometheus Operator, leave `serviceMonitor.enabled` at `false` and scrape
the Service directly:

```
release-name-vector.<namespace>.svc.cluster.local:9598/metrics
```

### Pipeline tuning

The Vector pipeline is defined in `config.vector.yaml`, rendered into a
ConfigMap and mounted at `configMountPath`. Replace it to wire your own sources,
transforms and sinks. For example, to ship logs to an Elasticsearch cluster:

```yaml
config:
  vector.yaml: |
    sources:
      app:
        type: kubernetes_logs
    sinks:
      es:
        type: elasticsearch
        inputs:
          - app
        endpoints:
          - http://elasticsearch.logging.svc:9200
        mode: bulk
```
