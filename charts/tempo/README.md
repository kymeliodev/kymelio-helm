# tempo

Tempo distributed tracing backend. This chart runs Tempo as a single binary StatefulSet with a local storage backend and an OTLP gRPC receiver. The configuration is rendered from a ConfigMap and mounted at `/etc/tempo/tempo.yaml`, with trace data kept on a persistent volume.

## Ports

| Name | Port | Purpose |
|------|------|---------|
| http | 3200 | Tempo HTTP API and query endpoint |
| otlp-grpc | 4317 | OTLP gRPC trace ingestion |

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-tempo kymelio/tempo
```

### OCI registry

```sh
helm install my-tempo oci://ghcr.io/kymeliodev/kymelio-helm/tempo --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-tempo
```

## Configuration

The Tempo configuration is provided through `config` as a YAML string and mounted at `/etc/tempo/tempo.yaml`. The default enables an OTLP gRPC receiver and a local filesystem storage backend. Additional Service and container ports are listed under `service.extraPorts`. A change to `config` updates a checksum annotation on the pod so it is rolled automatically.

### Monitoring

Tempo exposes its own metrics at `/metrics` on the HTTP port (`service.port`, default 3200). Set `metrics.enabled` to advertise the endpoint and create a ServiceMonitor for the Prometheus Operator:

```yaml
metrics:
  enabled: true
  serviceMonitor:
    enabled: true
    path: /metrics
    interval: 30s
    labels:
      release: kube-prometheus-stack
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `docker.io/grafana/tempo` | Container image repository |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| args | list | config.file | Command line arguments passed to Tempo |
| config | string | local storage with OTLP | Tempo configuration mounted as tempo.yaml |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `3200` | Primary HTTP service port |
| service.extraPorts | list | otlp-grpc 4317 | Additional Service and container ports |
| persistence.enabled | bool | `true` | Enable a persistent volume for /var/tempo |
| persistence.size | string | `8Gi` | Persistent volume size |
| persistence.mountPath | string | `/var/tempo` | Data directory mount path |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| metrics.enabled | bool | `false` | Advertise the built in /metrics endpoint on the HTTP port |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| metrics.serviceMonitor.path | string | `/metrics` | HTTP path scraped by the ServiceMonitor |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsUser 10001 | Pod security context |
| securityContext | object | drop ALL | Container security context |
