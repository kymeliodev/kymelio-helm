# prometheus

Prometheus monitoring system and time series database. This chart runs Prometheus as a single replica StatefulSet. The scrape configuration is rendered from a ConfigMap and mounted at `/etc/prometheus/prometheus.yml`, and time series data is kept on a persistent volume.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-prometheus kymelio/prometheus
```

### OCI registry

```sh
helm install my-prometheus oci://ghcr.io/kymeliodev/kymelio-helm/prometheus --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-prometheus
```

## Configuration

The Prometheus configuration is provided through `config` as a YAML string and mounted at `/etc/prometheus/prometheus.yml`. The default scrapes the Prometheus instance itself. A change to `config` updates a checksum annotation on the pod so it is rolled automatically.

```yaml
config: |
  global:
    scrape_interval: 30s
  scrape_configs:
    - job_name: prometheus
      static_configs:
        - targets:
            - localhost:9090
```

### Monitoring

Prometheus exposes its own metrics at `/metrics` on the HTTP port (`service.port`, default 9090) and scrapes itself by default. Set `metrics.enabled` to advertise the endpoint and create a ServiceMonitor for an external Prometheus Operator:

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
| image.repository | string | `docker.io/prom/prometheus` | Container image repository |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| args | list | config.file and storage.tsdb.path | Command line arguments passed to Prometheus |
| config | string | minimal self scrape | Prometheus configuration mounted as prometheus.yml |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `9090` | HTTP service port |
| persistence.enabled | bool | `true` | Enable a persistent volume for /prometheus |
| persistence.size | string | `8Gi` | Persistent volume size |
| persistence.mountPath | string | `/prometheus` | Data directory mount path |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| metrics.enabled | bool | `false` | Advertise the built in /metrics endpoint on the HTTP port |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| metrics.serviceMonitor.path | string | `/metrics` | HTTP path scraped by the ServiceMonitor |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsUser 65534 | Pod security context |
| securityContext | object | drop ALL | Container security context |
