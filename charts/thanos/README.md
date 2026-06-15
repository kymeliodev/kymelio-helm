# thanos

This chart deploys the Thanos Querier as a stateless Deployment. The Querier fans out queries to one or more Thanos stores and presents a unified, deduplicated view across Prometheus instances. It exposes an HTTP endpoint for the UI and API, and a gRPC endpoint for the Store API.

This chart only runs the Querier. Other Thanos components such as the sidecar, store gateway, compactor and receive are deployed separately. Point the Querier at them by adding `--store` arguments through `args`.

## Ports

| Name | Port | Purpose |
|------|------|---------|
| http | 10902 | Querier HTTP UI and API |
| grpc | 10901 | Store API gRPC endpoint |

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-thanos kymelio/thanos
```

### OCI registry

```sh
helm install my-thanos oci://ghcr.io/kymeliodev/kymelio-helm/thanos --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-thanos
```

## Connecting stores

Add store endpoints by overriding `args`, for example:

```yaml
args:
  - query
  - "--http-address=0.0.0.0:10902"
  - "--grpc-address=0.0.0.0:10901"
  - "--store=dnssrv+_grpc._tcp.thanos-store.monitoring.svc.cluster.local"
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `quay.io/thanos/thanos` | Container image repository |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| command | list | `["thanos"]` | Container entrypoint command |
| args | list | query with http and grpc addresses | Command line arguments passed to Thanos |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `10902` | Primary HTTP service port |
| service.extraPorts | list | grpc 10901 | Additional Service and container ports |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsUser 1001 | Pod security context |
| securityContext | object | drop ALL | Container security context |
