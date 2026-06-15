# jaeger

All in one distributed tracing backend, deployed as a single Deployment with in
memory span storage. The pod bundles the agent, collector, query service and
user interface. It accepts OpenTelemetry OTLP gRPC and Thrift collector traffic
and serves the query user interface over HTTP.

This release stores spans in memory and is not intended for production
retention. Spans are lost when the pod restarts.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-jaeger kymelio/jaeger
```

### OCI registry

```sh
helm install my-jaeger oci://ghcr.io/kymeliodev/kymelio-helm/jaeger --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-jaeger
```

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-jaeger kymelio/jaeger --reuse-values
```

## Ports

| Name | Port | Purpose |
|------|------|---------|
| ui | 16686 | Query user interface and API |
| otlp-grpc | 4317 | OpenTelemetry OTLP gRPC ingestion |
| collector | 14268 | Thrift over HTTP collector ingestion |
| admin | 14269 | Health check and Prometheus metrics (when metrics.enabled) |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `docker.io/jaegertracing/all-in-one` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `16686` | Primary user interface port |
| service.portName | string | `ui` | Primary named service port |
| service.ports | list | ui, otlp-grpc, collector | Service ports exposed by the workload |
| containerPorts | list | ui, otlp-grpc, collector | Container ports exposed by the all-in-one binary |
| extraEnv | list | COLLECTOR_OTLP_ENABLED, SPAN_STORAGE_TYPE | Environment variables for the container |
| ingress.enabled | bool | `false` | Enable an Ingress resource for the user interface |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Expose the admin port on a dedicated metrics Service port |
| metrics.port | int | `14269` | Admin port serving the metrics endpoint |
| metrics.path | string | `/metrics` | HTTP path where Jaeger exposes metrics |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor (requires metrics.enabled) |
| metrics.serviceMonitor.interval | string | `30s` | Scrape interval for the ServiceMonitor |
| metrics.serviceMonitor.scrapeTimeout | string | `10s` | Scrape timeout for the ServiceMonitor |
| metrics.serviceMonitor.labels | object | `{}` | Extra labels added to the ServiceMonitor |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 10001 | Pod security context |
| securityContext | object | drop ALL | Container security context |

## Configuration

### Prometheus metrics

The all-in-one binary serves Prometheus metrics at `/metrics` on its admin port
(`14269`). Set `metrics.enabled` to expose that port through a dedicated
`metrics` Service port and create a `ServiceMonitor` for the Prometheus
Operator:

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
release-name-jaeger.<namespace>.svc.cluster.local:14269/metrics
```

### Jaeger tuning

The all-in-one binary is configured through environment variables and flags.
Adjust `extraEnv` to change storage and feature settings, and append flags with
`extraArgs`. For example, to cap the in memory span store:

```yaml
extraEnv:
  - name: COLLECTOR_OTLP_ENABLED
    value: "true"
  - name: SPAN_STORAGE_TYPE
    value: memory
  - name: MEMORY_MAX_TRACES
    value: "50000"
```
