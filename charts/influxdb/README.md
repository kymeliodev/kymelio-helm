# influxdb

InfluxDB time series database, deployed as a single instance StatefulSet with
persistent storage.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-influxdb kymelio/influxdb
```

### OCI registry

```sh
helm install my-influxdb oci://ghcr.io/kymeliodev/kymelio-helm/influxdb --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-influxdb
```

The PersistentVolumeClaim is retained after uninstall. Delete it manually to
discard the data.

## Upgrading

Review the chart version change and your overridden values before upgrading. A
generated password is preserved across upgrades when you keep `auth.password`
empty and reuse the release Secret.

```sh
helm upgrade my-influxdb kymelio/influxdb
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas, fixed at one |
| image.repository | string | `docker.io/library/influxdb` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| auth.username | string | `admin` | Initial admin user created on first start |
| auth.org | string | `primary` | Initial organization created on first start |
| auth.bucket | string | `default` | Initial bucket created on first start |
| auth.password | string | `""` | Admin password, generated when empty |
| auth.existingSecret | string | `""` | Use an existing Secret for credentials |
| auth.secretKeys.passwordKey | string | `influxdb-password` | Secret key holding the password |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `8086` | Service port |
| persistence.enabled | bool | `true` | Enable a PersistentVolumeClaim |
| persistence.storageClass | string | `""` | StorageClass, empty uses the cluster default |
| persistence.size | string | `8Gi` | Size of the data volume |
| persistence.mountPath | string | `/var/lib/influxdb2` | Data directory mount path |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Scrape the native /metrics endpoint on the HTTP port |
| metrics.path | string | `/metrics` | Prometheus endpoint path |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| parameters | object | `{}` | Native influxd options applied as INFLUXD_ environment variables |
| tls.enabled | bool | `false` | Serve the API and UI over TLS via INFLUXD_TLS_CERT/INFLUXD_TLS_KEY |
| tls.existingSecret | string | `""` | Secret holding the certificate and key |

## Configuration

### Metrics

InfluxDB 2.x exposes a native Prometheus endpoint at `/metrics` on the HTTP port
(`8086`), so no exporter sidecar is needed. Enable scraping with:

```sh
helm install my-influxdb kymelio/influxdb \
  --set metrics.enabled=true \
  --set metrics.serviceMonitor.enabled=true
```

### Server tuning

Pass native `influxd` options through `parameters`. Each key becomes an
`INFLUXD_` environment variable (uppercased, dashes converted to underscores):

```yaml
parameters:
  query-concurrency: "20"
  storage-cache-max-memory-size: "1073741824"
```

### TLS

InfluxDB serves the API and UI over TLS when `tls-cert` and `tls-key` are set.
Provide a Secret with the certificate and key; the chart mounts it and wires
`INFLUXD_TLS_CERT` and `INFLUXD_TLS_KEY`:

```sh
helm install my-influxdb kymelio/influxdb \
  --set tls.enabled=true \
  --set tls.existingSecret=influxdb-tls
```
