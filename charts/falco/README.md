# falco

A Helm chart for falco.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-falco kymelio/falco
```

### OCI registry

```sh
helm install my-falco oci://ghcr.io/kymeliodev/kymelio-helm/falco --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-falco
```

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-falco kymelio/falco --reuse-values
```

## Configuration

### Metrics

Falco 0.38 and later expose Prometheus metrics at `/metrics` on the embedded web
server port (`8765`) when both the web server and the metrics block are enabled
in `falco.yaml`. Set `metrics.enabled=true` to publish a dedicated `metrics`
port on the Service, and `metrics.serviceMonitor.enabled=true` to create a
ServiceMonitor for the Prometheus Operator that scrapes the `/metrics` path.

You must also enable the metrics in the Falco configuration. Provide a
`falco.yaml` through `configuration` (mounted as a ConfigMap) that turns on the
web server and the Prometheus metrics exporter:

```yaml
metrics:
  enabled: true
  port: 8765
  serviceMonitor:
    enabled: true
    interval: 30s
    scrapeTimeout: 10s
    labels:
      release: kube-prometheus-stack

configuration: |
  webserver:
    enabled: true
    listen_port: 8765
    prometheus_metrics_enabled: true
  metrics:
    enabled: true
    interval: 1h
    output_rule: true
    resource_utilization_enabled: true
    state_counters_enabled: true
    kernel_event_counters_enabled: true
    libbpf_stats_enabled: true
```

### Falco flags

Append additional command line flags with `extraArgs`, for example to load extra
rules files or raise verbosity:

```yaml
extraArgs:
  - -r
  - /etc/falco/rules.d/custom_rules.yaml
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `""` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `8765` | Service port |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| podDisruptionBudget.enabled | bool | `false` | Enable a PodDisruptionBudget |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Publish a dedicated metrics port on the Service |
| metrics.port | int | `8765` | Service port for the metrics endpoint |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor scraping /metrics |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot | Pod security context |
| securityContext | object | drop ALL | Container security context |
