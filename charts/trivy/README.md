# trivy

A Helm chart for trivy.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-trivy kymelio/trivy
```

### OCI registry

```sh
helm install my-trivy oci://ghcr.io/kymeliodev/kymelio-helm/trivy --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-trivy
```

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-trivy kymelio/trivy --reuse-values
```

## Configuration

### Metrics

The Trivy server exposes Prometheus metrics at `/metrics` on its API port
(`4954`) when it is started with `--metrics`. Set `metrics.enabled=true` to add
that flag and publish a dedicated `metrics` port on the Service, and
`metrics.serviceMonitor.enabled=true` to create a ServiceMonitor for the
Prometheus Operator that scrapes the `/metrics` path.

```yaml
metrics:
  enabled: true
  port: 4954
  serviceMonitor:
    enabled: true
    interval: 30s
    scrapeTimeout: 10s
    labels:
      release: kube-prometheus-stack
```

The `--metrics` flag and the `/metrics` endpoint depend on the Trivy server
version in use. Confirm that your image exposes Prometheus metrics before
relying on the ServiceMonitor target.

### Server flags

The deployment runs `trivy server --listen 0.0.0.0:4954`. Append additional
server flags with `extraArgs`, for example to set the cache backend or the
token header:

```yaml
extraArgs:
  - --cache-backend=redis://trivy-redis:6379
  - --listen-jaeger=jaeger:6831
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `""` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `4954` | Service port |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| podDisruptionBudget.enabled | bool | `false` | Enable a PodDisruptionBudget |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Start the server with --metrics and publish a metrics port |
| metrics.port | int | `4954` | Service port for the metrics endpoint |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor scraping /metrics |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot | Pod security context |
| securityContext | object | drop ALL | Container security context |
