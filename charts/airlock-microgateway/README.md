# airlock-microgateway

A Helm chart for airlock-microgateway.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-airlock-microgateway kymelio/airlock-microgateway
```

### OCI registry

```sh
helm install my-airlock-microgateway oci://ghcr.io/kymeliodev/kymelio-helm/airlock-microgateway --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-airlock-microgateway
```

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-airlock-microgateway kymelio/airlock-microgateway --reuse-values
```

## Configuration

### Metrics

The Airlock Microgateway operator manager exposes Prometheus metrics at
`/metrics`. Set `metrics.enabled=true` to publish a dedicated `metrics` port on
the Service, and `metrics.serviceMonitor.enabled=true` to create a ServiceMonitor
for the Prometheus Operator that scrapes the `/metrics` path.

```yaml
metrics:
  enabled: true
  port: 8080
  serviceMonitor:
    enabled: true
    interval: 30s
    scrapeTimeout: 10s
    labels:
      release: kube-prometheus-stack
```

The manager metrics bind address depends on the operator build. Set
`metrics.port` to match the port your operator serves metrics on, and confirm
the endpoint is reachable before relying on the ServiceMonitor target.

### Operator flags

Append additional manager flags with `extraArgs`, for example to change the
metrics bind address or the log level:

```yaml
extraArgs:
  - --metrics-bind-address=:8080
  - --zap-log-level=debug
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `""` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `8080` | Service port |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| podDisruptionBudget.enabled | bool | `false` | Enable a PodDisruptionBudget |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Publish a dedicated metrics port on the Service |
| metrics.port | int | `8080` | Service port for the metrics endpoint |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor scraping /metrics |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot | Pod security context |
| securityContext | object | drop ALL | Container security context |
