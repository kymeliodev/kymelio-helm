# vernemq

VerneMQ MQTT broker, deployed as a StatefulSet with persistent storage. The MQTT
listener is published on port 1883 and EPMD on port 4369.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-vernemq kymelio/vernemq
```

### OCI registry

```sh
helm install my-vernemq oci://ghcr.io/kymeliodev/kymelio-helm/vernemq --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-vernemq
```

The PersistentVolumeClaim is retained after uninstall. Delete it manually to
discard the data.

## Upgrading

Review the chart version change and your overridden values before upgrading.

```sh
helm upgrade my-vernemq kymelio/vernemq
```

## Notes

The broker accepts the VerneMQ EULA through the `DOCKER_VERNEMQ_ACCEPT_EULA`
environment variable and enables anonymous access through
`DOCKER_VERNEMQ_ALLOW_ANONYMOUS`. Configure authentication before exposing the
broker outside the cluster.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `docker.io/vernemq/vernemq` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.mqtt.port | int | `1883` | MQTT listener port |
| service.epmd.port | int | `4369` | EPMD port |
| persistence.enabled | bool | `true` | Enable a PersistentVolumeClaim |
| persistence.storageClass | string | `""` | StorageClass, empty uses the cluster default |
| persistence.size | string | `8Gi` | Size of the data volume |
| persistence.mountPath | string | `/vernemq/data` | Mount path for the data volume |
| resources | object | requests and limits | Container resource requests and limits |
| securityContext | object | drop ALL | Container security context |
| podSecurityContext | object | runAsNonRoot 10000 | Pod security context |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Scrape the native /metrics endpoint on the HTTP status port |
| metrics.path | string | `/metrics` | Prometheus endpoint path |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| service.metrics.port | int | `8888` | HTTP status and metrics service port |
| vernemqConf | object | `{}` | Native settings applied as DOCKER_VERNEMQ_ environment variables |
| tls.enabled | bool | `false` | Serve the SSL MQTT listener via native settings |
| tls.existingSecret | string | `""` | Secret holding ca.crt, tls.crt and tls.key |
| tls.requireCertificate | bool | `false` | Require and verify client certificates |
| tls.mqttsPort | int | `8883` | SSL MQTT listener port published when TLS is enabled |

## Configuration

### Metrics

VerneMQ exposes a native Prometheus endpoint on its HTTP status listener
(port `8888`, path `/metrics`), so no exporter sidecar is required. The listener
binds to localhost by default, so enabling metrics rebinds it to `0.0.0.0` so
Prometheus can reach it, publishes the port and wires the ServiceMonitor to it.

```sh
helm install my-vernemq kymelio/vernemq \
  --set metrics.enabled=true \
  --set metrics.serviceMonitor.enabled=true
```

### Server tuning

Pass native VerneMQ settings through `vernemqConf`. Each key is a `vernemq.conf`
option that becomes a `DOCKER_VERNEMQ_` environment variable (uppercased, dots
converted to double underscores):

```yaml
vernemqConf:
  max_online_messages: "10000"
  allow_register_during_netsplit: "on"
```

### TLS

VerneMQ configures the SSL MQTT listener through native
`DOCKER_VERNEMQ_LISTENER__SSL__DEFAULT` settings. Provide a Secret with `ca.crt`,
`tls.crt` and `tls.key`; the chart mounts it, wires those settings and publishes
the SSL listener on `8883`:

```sh
helm install my-vernemq kymelio/vernemq \
  --set tls.enabled=true \
  --set tls.existingSecret=vernemq-tls \
  --set tls.requireCertificate=true
```
