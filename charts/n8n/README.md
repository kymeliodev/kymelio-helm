# n8n

[n8n](https://n8n.io) is a workflow automation tool for connecting apps and
services. It is deployed here as a StatefulSet.

By default n8n runs standalone on a SQLite database stored on the persistent
volume, so no external database is required.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-n8n kymelio/n8n
```

### OCI registry

```sh
helm install my-n8n oci://ghcr.io/kymeliodev/kymelio-helm/n8n --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-n8n
```

## Public address

When exposing n8n behind a proxy, set the host, protocol and webhook URL so that
generated links and webhook callbacks are correct:

```yaml
n8n:
  host: n8n.example.com
  protocol: https
  webhookUrl: https://n8n.example.com/
```

## Storage

The SQLite database and all user data live under `/home/node/.n8n`
(`persistence.mountPath`) on a PersistentVolumeClaim.

## Encryption key

`N8N_ENCRYPTION_KEY` secures stored credentials. It is generated on first
install and stored in the release Secret, then reused on upgrade so it stays
stable. Changing this key makes previously stored credentials unreadable. To
manage it yourself, set `auth.encryptionKey`, or create a Secret with the key
`encryption-key` and set `auth.existingSecret`.

## Upgrading

Review the chart version change and your overridden values before upgrading.

```sh
helm upgrade my-n8n kymelio/n8n
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `docker.io/n8nio/n8n` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| n8n.host | string | `localhost` | Hostname n8n is reached on |
| n8n.protocol | string | `http` | Protocol used in generated URLs |
| n8n.webhookUrl | string | `http://localhost:5678/` | Public URL used for webhook callbacks |
| auth.encryptionKey | string | `""` | Fixed encryption key, generated when empty |
| auth.existingSecret | string | `""` | Use an existing Secret for the encryption key |
| auth.secretKeys.encryptionKeyKey | string | `encryption-key` | Secret key holding N8N_ENCRYPTION_KEY |
| persistence.enabled | bool | `true` | Enable a PersistentVolumeClaim |
| persistence.size | string | `8Gi` | Size of the PersistentVolumeClaim |
| persistence.mountPath | string | `/home/node/.n8n` | Data directory mount path |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `5678` | Service port |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| podDisruptionBudget.enabled | bool | `false` | Enable a PodDisruptionBudget |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Enable the built in Prometheus metrics endpoint (sets `N8N_METRICS=true`) |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| metrics.serviceMonitor.interval | string | `30s` | Scrape interval |
| metrics.serviceMonitor.scrapeTimeout | string | `10s` | Scrape timeout |
| metrics.serviceMonitor.labels | object | `{}` | Extra labels for the ServiceMonitor |
| extraEnv | list | `[]` | Extra environment variables passed to the container |

## Configuration

n8n is configured through `N8N_*` and `DB_*` environment variables. The chart
wires the host, protocol, webhook URL, encryption key and SQLite storage, and
exposes `extraEnv` for any additional setting.

```yaml
n8n:
  host: n8n.example.com
  protocol: https
  webhookUrl: https://n8n.example.com/
extraEnv:
  - name: GENERIC_TIMEZONE
    value: Europe/Zurich
  - name: N8N_DEFAULT_BINARY_DATA_MODE
    value: filesystem
  - name: EXECUTIONS_DATA_PRUNE
    value: "true"
  - name: EXECUTIONS_DATA_MAX_AGE
    value: "336"
```

### Metrics

n8n exposes a built in Prometheus endpoint. Setting `metrics.enabled` exports
`N8N_METRICS=true` and serves metrics on the main HTTP port (`5678`) at
`/metrics`; the ServiceMonitor scrapes the `http` port on that path.

```yaml
metrics:
  enabled: true
  serviceMonitor:
    enabled: true
```

Additional metric groups are available through `extraEnv`, for example
`N8N_METRICS_INCLUDE_QUEUE_METRICS=true` or
`N8N_METRICS_INCLUDE_DEFAULT_METRICS=true`. The ServiceMonitor requires the
Prometheus Operator CRDs.

### Ingress and TLS

n8n serves plain HTTP on port `5678`. Terminate TLS at an ingress controller or
reverse proxy and set `n8n.protocol`, `n8n.host` and `n8n.webhookUrl` to the
external HTTPS address rather than configuring TLS on the application.
