# nats

NATS server with JetStream enabled, deployed as a single node StatefulSet with
persistent storage for the JetStream store directory.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-nats kymelio/nats
```

### OCI registry

```sh
helm install my-nats oci://ghcr.io/kymeliodev/kymelio-helm/nats --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-nats
```

The PersistentVolumeClaim is retained after uninstall. Delete it manually to
discard the JetStream data.

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-nats kymelio/nats
```

## Values

JetStream is enabled by default with the store directory set to `/data`.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `docker.io/library/nats` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.client.port | int | `4222` | Client port |
| service.http.port | int | `8222` | Monitoring HTTP port |
| persistence.enabled | bool | `true` | Enable a PersistentVolumeClaim |
| persistence.storageClass | string | `""` | StorageClass, empty uses the cluster default |
| persistence.size | string | `8Gi` | Size of the JetStream data volume |
| persistence.mountPath | string | `/data` | JetStream store directory mount path |
| resources | object | requests and limits | Container resource requests and limits |
| securityContext | object | drop ALL | Container security context |
| podSecurityContext | object | runAsNonRoot 1000 | Pod security context |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Add the prometheus-nats-exporter sidecar and publish its port |
| metrics.image.repository | string | `natsio/prometheus-nats-exporter` | Exporter sidecar image |
| metrics.image.tag | string | `0.15.0` | Exporter sidecar image tag |
| metrics.collectors | list | `["-varz"]` | NATS monitoring subsystems collected by the exporter |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| service.metrics.port | int | `7777` | Exporter metrics service port |
| natsConf | object | `{}` | Native settings rendered into nats-server.conf |
| tls.enabled | bool | `false` | Serve TLS using a native tls block |
| tls.existingSecret | string | `""` | Secret holding ca.crt, tls.crt and tls.key |
| tls.verify | bool | `false` | Require and verify client certificates |

## Configuration

### Metrics

NATS exposes monitoring data as JSON on the HTTP port (`8222`) rather than in
Prometheus format. The community `prometheus-nats-exporter` sidecar reads that
endpoint and re-exposes it as Prometheus metrics on its own port (`7777`).
Enabling metrics adds the sidecar, publishes its port and wires the
ServiceMonitor to it.

```sh
helm install my-nats kymelio/nats \
  --set metrics.enabled=true \
  --set metrics.serviceMonitor.enabled=true
```

Collect additional subsystems by extending `metrics.collectors`, for example
`{-varz, -connz, -jsz=all}`.

### Server tuning

Pass native server settings through `natsConf`. Each key/value pair is rendered
into `nats-server.conf`, mounted at `/etc/nats/nats-server.conf` and loaded with
`-c`:

```yaml
natsConf:
  max_payload: 8MB
  max_connections: "100000"
```

### TLS

NATS configures TLS through a native `tls {}` block. Provide a Secret with
`ca.crt`, `tls.crt` and `tls.key`; the chart mounts it, renders the block into
`nats-server.conf` and starts the server with that config:

```sh
helm install my-nats kymelio/nats \
  --set tls.enabled=true \
  --set tls.existingSecret=nats-tls \
  --set tls.verify=true
```
