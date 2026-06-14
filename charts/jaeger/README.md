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
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 10001 | Pod security context |
| securityContext | object | drop ALL | Container security context |
