# clickhouse

ClickHouse OLAP database, deployed as a single node StatefulSet with persistent
storage. Default access management is enabled and the user password is stored in
a Kubernetes Secret.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-clickhouse kymelio/clickhouse
```

### OCI registry

```sh
helm install my-clickhouse oci://ghcr.io/kymeliodev/kymelio-helm/clickhouse --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-clickhouse
```

The PersistentVolumeClaim is retained after uninstall. Delete it manually to
discard the data.

## Upgrading

Review the chart version change and your overridden values before upgrading. A
generated password is preserved across upgrades when you keep `auth.password`
empty and reuse the release Secret.

```sh
helm upgrade my-clickhouse kymelio/clickhouse
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas, fixed at one |
| image.repository | string | `docker.io/clickhouse/clickhouse-server` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| auth.username | string | `default` | User created on first start |
| auth.database | string | `default` | Database created on first start |
| auth.password | string | `""` | User password, generated when empty |
| auth.existingSecret | string | `""` | Use an existing Secret for credentials |
| auth.secretKeys.passwordKey | string | `clickhouse-password` | Secret key holding the password |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.ports.native.port | int | `9000` | Native protocol port |
| service.ports.http.port | int | `8123` | HTTP interface port |
| persistence.enabled | bool | `true` | Enable a PersistentVolumeClaim |
| persistence.storageClass | string | `""` | StorageClass, empty uses the cluster default |
| persistence.size | string | `8Gi` | Size of the data volume |
| persistence.mountPath | string | `/var/lib/clickhouse` | Data volume mount path |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 101 | Pod security context |
| securityContext | object | drop ALL | Container security context |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Enable the native Prometheus endpoint and metrics port |
| metrics.port | int | `9363` | Prometheus endpoint port |
| metrics.path | string | `/metrics` | Prometheus endpoint path |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| serverConfig | string | `""` | XML drop-in rendered under config.d for native tuning |
| tls.enabled | bool | `false` | Mount a certificate Secret and render an openSSL drop-in |
| tls.existingSecret | string | `""` | Secret holding the certificate and key |

## Configuration

### Metrics

ClickHouse exposes a native Prometheus endpoint through its `<prometheus>`
server config section. Enabling metrics renders that section as an XML drop-in
under `/etc/clickhouse-server/config.d`, publishes port `9363` and serves
`/metrics`:

```sh
helm install my-clickhouse kymelio/clickhouse \
  --set metrics.enabled=true \
  --set metrics.serviceMonitor.enabled=true
```

### Server tuning

Use `serverConfig` to provide an XML document that is rendered as a drop-in
under `config.d`. This is the vendor mechanism for native settings:

```yaml
serverConfig: |
  <clickhouse>
    <max_concurrent_queries>200</max_concurrent_queries>
    <logger>
      <level>information</level>
    </logger>
  </clickhouse>
```

### TLS

ClickHouse configures TLS through its XML config (`<openSSL>`, `<https_port>`,
`<tcp_port_secure>`). Provide a Secret with the certificate and key; the chart
mounts it and renders an `<openSSL>` drop-in that references the mounted files.
Open the secure ports you need through `serverConfig`:

```sh
helm install my-clickhouse kymelio/clickhouse \
  --set tls.enabled=true \
  --set tls.existingSecret=clickhouse-tls \
  --set-string serverConfig='<clickhouse><https_port>8443</https_port></clickhouse>'
```
