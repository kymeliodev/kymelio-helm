# questdb

QuestDB high performance time series database, deployed as a single
StatefulSet with persistent storage. The chart exposes the http web console
and REST API alongside the PostgreSQL wire protocol.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-questdb kymelio/questdb
```

### OCI registry

```sh
helm install my-questdb oci://ghcr.io/kymeliodev/kymelio-helm/questdb --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-questdb
```

The PersistentVolumeClaim is retained after uninstall. Delete it manually to
discard the data.

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-questdb kymelio/questdb
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas, fixed at one |
| image.repository | string | `docker.io/questdb/questdb` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.ports.http | int | `9000` | Web console and REST API port |
| service.ports.postgres | int | `8812` | PostgreSQL wire protocol port |
| service.primaryPortName | string | `http` | Port used by probes, NOTES and the test |
| persistence.enabled | bool | `true` | Enable a PersistentVolumeClaim |
| persistence.storageClass | string | `""` | StorageClass, empty uses the cluster default |
| persistence.size | string | `8Gi` | Size of the data volume |
| persistence.mountPath | string | `/var/lib/questdb` | Mount path for the data volume |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 10001 | Pod security context |
| securityContext | object | drop ALL | Container security context |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Set QDB_METRICS_ENABLED and publish the metrics port |
| metrics.port | int | `9003` | Native metrics endpoint port |
| metrics.path | string | `/metrics` | Metrics endpoint path |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| serverConf | string | `""` | Native server.conf content mounted into the config directory |
| tls.enabled | bool | `false` | Mount a certificate Secret for server.conf TLS references |
| tls.existingSecret | string | `""` | Secret holding the certificate and key |

## Configuration

### Metrics

QuestDB exposes a native Prometheus endpoint on port `9003` at `/metrics`, which
must be enabled with `QDB_METRICS_ENABLED`. Enabling metrics sets that variable
and publishes the port:

```sh
helm install my-questdb kymelio/questdb \
  --set metrics.enabled=true \
  --set metrics.serviceMonitor.enabled=true
```

### Server tuning

Provide native `server.conf` settings through `serverConf`. The content is
rendered into a ConfigMap and mounted as `server.conf` in the QuestDB config
directory:

```yaml
serverConf: |
  shared.worker.count=4
  cairo.commit.lag=2000
```

### TLS

In open source QuestDB, native TLS is configured through `server.conf`
(`http.tls.enabled`, `http.tls.cert.path`, `http.tls.private.key.path`); full
TLS termination is an Enterprise feature. Enabling `tls` mounts the certificate
Secret so it can be referenced from `serverConf`:

```sh
helm install my-questdb kymelio/questdb \
  --set tls.enabled=true \
  --set tls.existingSecret=questdb-tls \
  --set serverConf=$'http.tls.enabled=true\nhttp.tls.cert.path=/etc/questdb/certs/tls.crt\nhttp.tls.private.key.path=/etc/questdb/certs/tls.key'
```
