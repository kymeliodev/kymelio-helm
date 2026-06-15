# opentelemetry-collector

Vendor neutral collector for receiving, processing and exporting telemetry,
deployed as a single Deployment. The pipeline accepts OTLP gRPC and HTTP
traffic, guards memory with the memory_limiter processor, batches records and
exports them to the debug logger. The health_check extension is served on port
13133.

The collector configuration is rendered from `config` into a ConfigMap and
mounted at `configMountPath` via subPath. A `checksum/config` annotation rolls
the pods when the configuration changes.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-opentelemetry-collector kymelio/opentelemetry-collector
```

### OCI registry

```sh
helm install my-opentelemetry-collector oci://ghcr.io/kymeliodev/kymelio-helm/opentelemetry-collector --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-opentelemetry-collector
```

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-opentelemetry-collector kymelio/opentelemetry-collector --reuse-values
```

## Ports

| Name | Port | Purpose |
|------|------|---------|
| otlp-grpc | 4317 | OTLP gRPC receiver |
| otlp-http | 4318 | OTLP HTTP receiver |
| health | 13133 | health_check extension |
| metrics | 8888 | Internal Prometheus telemetry (when metrics.enabled) |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `docker.io/otel/opentelemetry-collector-contrib` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| args | list | config flag | Command line flags for the collector binary |
| config | object | OTLP pipeline | Collector configuration rendered into a ConfigMap |
| configMountPath | string | `/etc/otelcol/config.yaml` | Mount path of the configuration file |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `4317` | Primary OTLP gRPC port |
| service.portName | string | `otlp-grpc` | Primary named service port |
| service.ports | list | otlp-grpc, otlp-http, health | Service ports exposed by the workload |
| containerPorts | list | otlp-grpc, otlp-http, health | Container ports exposed by the collector |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Publish a dedicated metrics Service port for the collector telemetry endpoint |
| metrics.port | int | `8888` | Port published on the Service and container for the metrics endpoint |
| metrics.path | string | `/metrics` | HTTP path where the collector exposes its internal metrics |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor (requires metrics.enabled) |
| metrics.serviceMonitor.interval | string | `30s` | Scrape interval for the ServiceMonitor |
| metrics.serviceMonitor.scrapeTimeout | string | `10s` | Scrape timeout for the ServiceMonitor |
| metrics.serviceMonitor.labels | object | `{}` | Extra labels added to the ServiceMonitor |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 10001 | Pod security context |
| securityContext | object | drop ALL | Container security context |

## Configuration

### Prometheus metrics

The collector exposes its own internal telemetry over a Prometheus endpoint at
`/metrics` on port `8888`. This endpoint is controlled by the collector
configuration, not by the chart. Set `metrics.enabled` to publish a dedicated
`metrics` Service and container port, and add a Prometheus reader to the
`config` so the endpoint binds to `0.0.0.0` (the default binds to localhost,
which is not reachable from outside the pod):

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
  config.yaml: |
    extensions:
      health_check:
        endpoint: 0.0.0.0:13133
    receivers:
      otlp:
        protocols:
          grpc:
            endpoint: 0.0.0.0:4317
          http:
            endpoint: 0.0.0.0:4318
    processors:
      batch: {}
    exporters:
      debug:
        verbosity: detailed
    service:
      telemetry:
        metrics:
          readers:
            - pull:
                exporter:
                  prometheus:
                    host: 0.0.0.0
                    port: 8888
      extensions:
        - health_check
      pipelines:
        traces:
          receivers: [otlp]
          processors: [batch]
          exporters: [debug]
```

If you do not run the Prometheus Operator, leave `serviceMonitor.enabled` at
`false` and scrape the Service directly:

```
release-name-opentelemetry-collector.<namespace>.svc.cluster.local:8888/metrics
```

### Pipeline tuning

The collector pipeline is defined in `config.config.yaml`, rendered into a
ConfigMap and mounted at `configMountPath`. Edit it to add receivers,
processors and exporters. For example, to forward traces to an OTLP backend:

```yaml
config:
  config.yaml: |
    receivers:
      otlp:
        protocols:
          grpc:
            endpoint: 0.0.0.0:4317
    processors:
      batch: {}
    exporters:
      otlp:
        endpoint: tempo.observability.svc:4317
        tls:
          insecure: true
    service:
      pipelines:
        traces:
          receivers: [otlp]
          processors: [batch]
          exporters: [otlp]
```
