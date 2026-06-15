# surrealdb

SurrealDB multi-model database, deployed as a single StatefulSet with
persistent storage backed by the rocksdb engine.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-surrealdb kymelio/surrealdb
```

### OCI registry

```sh
helm install my-surrealdb oci://ghcr.io/kymeliodev/kymelio-helm/surrealdb --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-surrealdb
```

The PersistentVolumeClaim is retained after uninstall. Delete it manually to
discard the data.

## Upgrading

Review the chart version change and your overridden values before upgrading. A
generated password is preserved across upgrades when you keep `auth.password`
empty and reuse the release Secret.

```sh
helm upgrade my-surrealdb kymelio/surrealdb
```

## Configuration

### Metrics

SurrealDB exposes Prometheus metrics on the main HTTP port at `/metrics` when
telemetry is enabled. Enabling metrics sets `SURREAL_TELEMETRY_PROVIDER` and points
the ServiceMonitor at `/metrics` on the existing service port.

```yaml
metrics:
  enabled: true
  serviceMonitor:
    enabled: true
```

### Config tuning

SurrealDB is configured through `surreal start` flags. Append any flag through
`extraArgs`:

```yaml
extraArgs:
  - --log
  - debug
  - --no-banner
  - --auth-level
  - record
```

### TLS

SurrealDB serves HTTP over TLS when given a certificate and key. Provide a Secret and
enable `tls`; the chart passes `--web-crt` and `--web-key`:

```sh
helm install my-surrealdb kymelio/surrealdb \
  --set tls.enabled=true \
  --set tls.existingSecret=surrealdb-tls
```

The Secret is mounted read only at `tls.mountPath`.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas, fixed at one |
| image.repository | string | `docker.io/surrealdb/surrealdb` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| auth.username | string | `root` | Root user created on first start |
| auth.password | string | `""` | Root password, generated when empty |
| auth.existingSecret | string | `""` | Use an existing Secret for credentials |
| auth.secretKeys.passwordKey | string | `surrealdb-password` | Secret key holding the password |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `8000` | Service port |
| persistence.enabled | bool | `true` | Enable a PersistentVolumeClaim |
| persistence.storageClass | string | `""` | StorageClass, empty uses the cluster default |
| persistence.size | string | `8Gi` | Size of the data volume |
| persistence.mountPath | string | `/data` | Mount path for the data volume |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Enable telemetry and expose /metrics on the HTTP port |
| metrics.path | string | `/metrics` | Path metrics are served at |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| tls.enabled | bool | `false` | Serve HTTP over TLS using --web-crt and --web-key |
| tls.existingSecret | string | `""` | Secret holding the certificate and key |
