# rabbitmq

Multi protocol message broker implementing AMQP, deployed as a single node
StatefulSet with the management plugin enabled and persistent storage.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-rabbitmq kymelio/rabbitmq
```

### OCI registry

```sh
helm install my-rabbitmq oci://ghcr.io/kymeliodev/kymelio-helm/rabbitmq --version 0.1.1
```

## Uninstall

```sh
helm uninstall my-rabbitmq
```

The PersistentVolumeClaim is retained after uninstall. Delete it manually to
discard the data.

## Upgrading

Review the chart version change and your overridden values before upgrading. A
generated password and Erlang cookie are preserved across upgrades when you
keep `auth.password` and `auth.erlangCookie` empty and reuse the release Secret.

```sh
helm upgrade my-rabbitmq kymelio/rabbitmq
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas, fixed at one node |
| image.repository | string | `docker.io/library/rabbitmq` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `3.13-management` | Image tag, the management variant ships the management UI |
| auth.username | string | `user` | Default user created on first start |
| auth.password | string | `""` | Default user password, generated when empty |
| auth.erlangCookie | string | `""` | Erlang cookie shared by nodes, generated when empty |
| auth.existingSecret | string | `""` | Use an existing Secret for credentials |
| auth.secretKeys.passwordKey | string | `rabbitmq-password` | Secret key holding the password |
| auth.secretKeys.erlangCookieKey | string | `rabbitmq-erlang-cookie` | Secret key holding the Erlang cookie |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.amqp.port | int | `5672` | AMQP service port |
| service.amqp.portName | string | `amqp` | AMQP port name |
| service.management.port | int | `15672` | Management UI service port |
| service.management.portName | string | `management` | Management port name |
| persistence.enabled | bool | `true` | Enable a PersistentVolumeClaim |
| persistence.storageClass | string | `""` | StorageClass, empty uses the cluster default |
| persistence.size | string | `8Gi` | Size of the data volume |
| persistence.mountPath | string | `/var/lib/rabbitmq` | Mount path of the data volume |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 999 | Pod security context |
| securityContext | object | drop ALL | Container security context |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Enable the rabbitmq_prometheus plugin and publish the metrics port |
| metrics.path | string | `/metrics` | Path the Prometheus plugin serves metrics on |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| service.metrics.port | int | `15692` | Prometheus metrics service port |
| service.metrics.portName | string | `metrics` | Prometheus metrics port name |
| rabbitmqConf | object | `{}` | Native settings rendered into rabbitmq.conf |
| tls.enabled | bool | `false` | Serve AMQPS using native ssl_options |
| tls.existingSecret | string | `""` | Secret holding ca.crt, tls.crt and tls.key |
| tls.amqpsPort | int | `5671` | AMQPS listener port published when TLS is enabled |
| tls.verifyPeer | bool | `false` | Require and verify client certificates |

## Configuration

### Metrics

RabbitMQ ships the `rabbitmq_prometheus` plugin, which exposes all broker
metrics in Prometheus text format on a dedicated port (`15692`, path
`/metrics`). Enabling metrics renders an `enabled_plugins` file that turns the
plugin on alongside the management plugin, publishes the metrics port and wires
the ServiceMonitor to it. No exporter sidecar is required.

```sh
helm install my-rabbitmq kymelio/rabbitmq \
  --set metrics.enabled=true \
  --set metrics.serviceMonitor.enabled=true
```

### Broker tuning

Pass native broker settings through `rabbitmqConf`. Each key/value pair is
rendered into `rabbitmq.conf` and mounted at `/etc/rabbitmq/rabbitmq.conf`:

```yaml
rabbitmqConf:
  vm_memory_high_watermark.relative: "0.6"
  channel_max: "2048"
  default_vhost: "/"
```

### TLS

RabbitMQ enables TLS through `ssl_options` in `rabbitmq.conf`. Provide a Secret
with `ca.crt`, `tls.crt` and `tls.key`; the chart mounts it, appends the
matching `ssl_options` and publishes the AMQPS listener on `tls.amqpsPort`:

```sh
helm install my-rabbitmq kymelio/rabbitmq \
  --set tls.enabled=true \
  --set tls.existingSecret=rabbitmq-tls \
  --set tls.verifyPeer=true
```
