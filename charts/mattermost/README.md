# mattermost

A Helm chart for mattermost.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-mattermost kymelio/mattermost
```

### OCI registry

```sh
helm install my-mattermost oci://ghcr.io/kymeliodev/kymelio-helm/mattermost --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-mattermost
```

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-mattermost kymelio/mattermost --reuse-values
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
| metrics.enabled | bool | `false` | Enable the built in Prometheus metrics listener (sets `MM_METRICSSETTINGS_ENABLE=true`) |
| metrics.port | int | `8067` | Container and Service port for the metrics listener |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| metrics.serviceMonitor.interval | string | `30s` | Scrape interval |
| metrics.serviceMonitor.scrapeTimeout | string | `10s` | Scrape timeout |
| metrics.serviceMonitor.labels | object | `{}` | Extra labels for the ServiceMonitor |
| extraEnv | list | `[]` | Extra environment variables passed to the container |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot | Pod security context |
| securityContext | object | drop ALL | Container security context |

## Configuration

Mattermost reads its configuration from `config.json` and from environment
variables of the form `MM_<SECTION>_<SETTING>`. Use `extraEnv` to set any
supported variable without templating a full config file.

```yaml
extraEnv:
  - name: MM_SQLSETTINGS_DRIVERNAME
    value: postgres
  - name: MM_SQLSETTINGS_DATASOURCE
    value: postgres://user:pass@postgresql:5432/mattermost?sslmode=disable
  - name: MM_SERVICESETTINGS_SITEURL
    value: https://chat.example.com
  - name: MM_FILESETTINGS_MAXFILESIZE
    value: "52428800"
```

### Metrics

Mattermost exposes a built in Prometheus endpoint. Setting `metrics.enabled`
exports `MM_METRICSSETTINGS_ENABLE=true` and `MM_METRICSSETTINGS_LISTENADDRESS`,
opens container and Service port `8067`, and points the ServiceMonitor at the
`/metrics` path on that port.

```yaml
metrics:
  enabled: true
  serviceMonitor:
    enabled: true
    interval: 30s
```

Note: scraping `/metrics` over HTTP requires a Mattermost Enterprise license.
The Team Edition image shipped by this chart opens the listener, but the
endpoint stays gated by the license. The ServiceMonitor requires the Prometheus
Operator CRDs to be installed in the cluster.

### Ingress and TLS

Mattermost serves plain HTTP on port `8065` and is intended to sit behind an
ingress controller or reverse proxy that terminates TLS. Enable `ingress` and
provide `ingress.tls` rather than configuring TLS on the application itself.

```yaml
ingress:
  enabled: true
  className: nginx
  hosts:
    - host: chat.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: mattermost-tls
      hosts:
        - chat.example.com
```
