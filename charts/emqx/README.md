# emqx

EMQX MQTT broker, deployed as a StatefulSet with persistent storage. The chart
publishes the MQTT listener and the management dashboard as separate service
ports.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-emqx kymelio/emqx
```

### OCI registry

```sh
helm install my-emqx oci://ghcr.io/kymeliodev/kymelio-helm/emqx --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-emqx
```

The PersistentVolumeClaim is retained after uninstall. Delete it manually to
discard the data.

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-emqx kymelio/emqx --reuse-values
```

## Dashboard

The management dashboard is served on port 18083. The image ships with the
default credentials `admin` / `public`. Change the password after the first
login.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `docker.io/emqx/emqx` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.mqtt.port | int | `1883` | MQTT listener port |
| service.dashboard.port | int | `18083` | Management dashboard port |
| persistence.enabled | bool | `true` | Enable a PersistentVolumeClaim |
| persistence.storageClass | string | `""` | StorageClass, empty uses the cluster default |
| persistence.size | string | `8Gi` | Size of the data volume |
| persistence.mountPath | string | `/opt/emqx/data` | Mount path for the data volume |
| resources | object | requests and limits | Container resource requests and limits |
| securityContext | object | drop ALL | Container security context |
| podSecurityContext | object | runAsNonRoot 1000 | Pod security context |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Scrape the native Prometheus endpoint on the dashboard port |
| metrics.path | string | `/api/v5/prometheus/stats` | Prometheus endpoint path |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| emqxConf | object | `{}` | Native EMQX settings applied as EMQX_ environment variables |
| tls.enabled | bool | `false` | Serve the SSL MQTT listener via native settings |
| tls.existingSecret | string | `""` | Secret holding ca.crt, tls.crt and tls.key |
| tls.verifyPeer | bool | `false` | Require and verify client certificates |
| service.mqttssl.port | int | `8883` | SSL MQTT listener port published when TLS is enabled |

## Configuration

### Metrics

EMQX exposes a native Prometheus endpoint on the dashboard port (`18083`) at
`/api/v5/prometheus/stats`, so no exporter sidecar is required. Basic auth on
the endpoint is disabled by default in EMQX, which keeps the scrape
unauthenticated. Enable scraping with:

```sh
helm install my-emqx kymelio/emqx \
  --set metrics.enabled=true \
  --set metrics.serviceMonitor.enabled=true
```

### Server tuning

Pass native EMQX settings through `emqxConf`. Each key is a dotted config path
that becomes an `EMQX_` environment variable (uppercased, dots converted to
double underscores):

```yaml
emqxConf:
  mqtt.max_packet_size: "1MB"
  node.process_limit: "2097152"
```

### TLS

EMQX configures the SSL MQTT listener through native
`EMQX_LISTENERS__SSL__DEFAULT__*` settings. Provide a Secret with `ca.crt`,
`tls.crt` and `tls.key`; the chart mounts it, wires those settings and publishes
the SSL listener on `8883`:

```sh
helm install my-emqx kymelio/emqx \
  --set tls.enabled=true \
  --set tls.existingSecret=emqx-tls \
  --set tls.verifyPeer=true
```
