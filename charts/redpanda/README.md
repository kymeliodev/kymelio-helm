# redpanda

Redpanda Kafka-compatible streaming data platform, deployed as a single node
StatefulSet with persistent storage.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-redpanda kymelio/redpanda
```

### OCI registry

```sh
helm install my-redpanda oci://ghcr.io/kymeliodev/kymelio-helm/redpanda --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-redpanda
```

The PersistentVolumeClaim is retained after uninstall. Delete it manually to
discard the data.

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-redpanda kymelio/redpanda
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `docker.redpanda.com/redpandadata/redpanda` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.kafka.port | int | `9092` | Kafka API service port |
| service.admin.port | int | `9644` | Admin API service port |
| persistence.enabled | bool | `true` | Enable a PersistentVolumeClaim |
| persistence.storageClass | string | `""` | StorageClass, empty uses the cluster default |
| persistence.size | string | `8Gi` | Size of the data volume |
| persistence.mountPath | string | `/var/lib/redpanda/data` | Data directory mount path |
| resources | object | requests and limits | Container resource requests and limits |
| securityContext | object | drop ALL | Container security context |
| podSecurityContext | object | runAsNonRoot 101 | Pod security context |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Wire monitoring to the native Redpanda metrics endpoint on the admin port |
| metrics.path | string | `/public_metrics` | Admin API metrics path (/public_metrics or /metrics) |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| redpandaConf | object | `{}` | Native broker settings applied as redpanda.yaml start flags |
| tls.enabled | bool | `false` | Serve the Kafka API over TLS using native redpanda.yaml configuration |
| tls.existingSecret | string | `""` | Secret holding ca.crt, tls.crt and tls.key |
| tls.requireClientAuth | bool | `false` | Require and verify client certificates |

## Configuration

### Metrics

Redpanda exposes Prometheus metrics on the admin API port (`9644`) under two
paths: `/public_metrics` (curated, low cardinality, `redpanda_` prefix) and
`/metrics` (detailed, `vectorized_` prefix). No exporter sidecar is required.
Enabling metrics wires the ServiceMonitor to the admin port and the chosen path:

```sh
helm install my-redpanda kymelio/redpanda \
  --set metrics.enabled=true \
  --set metrics.serviceMonitor.enabled=true
```

Switch to the detailed set with `--set metrics.path=/metrics`.

### Broker tuning

Pass native broker settings through `redpandaConf`. Each key/value pair is
applied as a `--set redpanda.<key>=<value>` start flag, which the broker writes
into `redpanda.yaml` before start:

```yaml
redpandaConf:
  auto_create_topics_enabled: "true"
  default_topic_replications: "1"
  log_segment_size: "134217728"
```

Free form start flags can also be appended through `extraArgs`, and the generic
`configuration` surface remains available for mounting a full `redpanda.yaml`.

### TLS

Redpanda enables Kafka API TLS through the `kafka_api_tls` section of
`redpanda.yaml`. Provide a Secret with `ca.crt`, `tls.crt` and `tls.key`; the
chart mounts it and passes the matching overrides as start flags:

```sh
helm install my-redpanda kymelio/redpanda \
  --set tls.enabled=true \
  --set tls.existingSecret=redpanda-tls \
  --set tls.requireClientAuth=true
```
