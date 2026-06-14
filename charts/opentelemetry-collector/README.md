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
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 10001 | Pod security context |
| securityContext | object | drop ALL | Container security context |
