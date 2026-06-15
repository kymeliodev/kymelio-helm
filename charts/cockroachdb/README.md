# cockroachdb

CockroachDB distributed SQL database, deployed as a single insecure node
StatefulSet with persistent storage.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-cockroachdb kymelio/cockroachdb
```

### OCI registry

```sh
helm install my-cockroachdb oci://ghcr.io/kymeliodev/kymelio-helm/cockroachdb --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-cockroachdb
```

The PersistentVolumeClaim is retained after uninstall. Delete it manually to
discard the data.

## Upgrading

Review the chart version change and your overridden values before upgrading.

```sh
helm upgrade my-cockroachdb kymelio/cockroachdb
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas, fixed at one |
| image.repository | string | `docker.io/cockroachdb/cockroach` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.ports.sql.port | int | `26257` | SQL endpoint port |
| service.ports.http.port | int | `8080` | Admin HTTP UI port |
| persistence.enabled | bool | `true` | Enable a PersistentVolumeClaim |
| persistence.storageClass | string | `""` | StorageClass, empty uses the cluster default |
| persistence.size | string | `8Gi` | Size of the data volume |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Publish a metrics Service port targeting the HTTP endpoint |
| metrics.port | int | `8081` | Service port used for scraping |
| metrics.path | string | `/_status/vars` | Prometheus endpoint path |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| parameters | object | `{}` | Start flags applied as `--key=value` to start-single-node |
| tls.enabled | bool | `false` | Start the node in secure mode with `--certs-dir` |
| tls.existingSecret | string | `""` | Secret holding ca.crt, node.crt and node.key |

## Configuration

### Metrics

CockroachDB exposes Prometheus metrics natively on the HTTP port at the
`/_status/vars` path, so no exporter sidecar is needed. Enable the metrics
Service port and a ServiceMonitor with:

```sh
helm install my-cockroachdb kymelio/cockroachdb \
  --set metrics.enabled=true \
  --set metrics.serviceMonitor.enabled=true
```

The ServiceMonitor scrapes the `metrics` port at `/_status/vars`.

### Server tuning

Pass native start flags through `parameters`. Each entry becomes a
`--key=value` argument to `start-single-node`:

```yaml
parameters:
  cache: 25%
  max-sql-memory: 25%
```

Or with `--set`:

```sh
helm install my-cockroachdb kymelio/cockroachdb --set parameters.cache=25%
```

### TLS

Provide a Secret containing the CockroachDB node certificate files
(`ca.crt`, `node.crt`, `node.key`). When enabled the node starts in secure mode
with `--certs-dir` instead of `--insecure`:

```sh
helm install my-cockroachdb kymelio/cockroachdb \
  --set tls.enabled=true \
  --set tls.existingSecret=cockroachdb-certs
```
