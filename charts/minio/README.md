# minio

High performance S3 compatible object storage, deployed as a single node
StatefulSet with persistent storage.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-minio kymelio/minio
```

### OCI registry

```sh
helm install my-minio oci://ghcr.io/kymeliodev/kymelio-helm/minio --version 0.1.1
```

## Uninstall

```sh
helm uninstall my-minio
```

The PersistentVolumeClaim is retained after uninstall. Delete it manually to
discard the stored objects.

## Upgrading

Review the chart version change and your overridden values before upgrading. A
generated root password is preserved across upgrades when you keep
`auth.rootPassword` empty and reuse the release Secret.

```sh
helm upgrade my-minio kymelio/minio
```

## Configuration

### Metrics

Enable the Prometheus metrics endpoint. MinIO exposes cluster metrics at
`/minio/v2/metrics/cluster` on the API port. Enabling metrics sets
`MINIO_PROMETHEUS_AUTH_TYPE=public` so the endpoint can be scraped without a
bearer token, and `metrics.serviceMonitor.enabled` creates a ServiceMonitor that
scrapes that path.

```sh
helm install my-minio kymelio/minio \
  --set metrics.enabled=true \
  --set metrics.serviceMonitor.enabled=true
```

### TLS

MinIO serves HTTPS when a certificate and key are mounted in its certs
directory. Provide a Secret containing the certificate and key, which are
projected to `public.crt` and `private.key` under `/root/.minio/certs`.

```sh
kubectl create secret tls minio-tls --cert=public.crt --key=private.key

helm install my-minio kymelio/minio \
  --set tls.enabled=true \
  --set tls.existingSecret=minio-tls
```

### Server parameters

Tune the server with `parameters`, which are passed as `MINIO_<KEY>`
environment variables.

```yaml
parameters:
  MINIO_STORAGE_CLASS_STANDARD: "EC:2"
  MINIO_API_REQUESTS_MAX: "1600"
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `quay.io/minio/minio` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| auth.rootUser | string | `minioadmin` | Root user stored in the Secret |
| auth.rootPassword | string | `""` | Root password, generated when empty |
| auth.existingSecret | string | `""` | Use an existing Secret for credentials |
| auth.secretKeys.rootUserKey | string | `root-user` | Secret key holding the root user |
| auth.secretKeys.rootPasswordKey | string | `root-password` | Secret key holding the root password |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.api.port | int | `9000` | S3 API service port |
| service.api.portName | string | `api` | S3 API port name |
| service.console.port | int | `9001` | Console service port |
| service.console.portName | string | `console` | Console port name |
| persistence.enabled | bool | `true` | Enable a PersistentVolumeClaim |
| persistence.storageClass | string | `""` | StorageClass, empty uses the cluster default |
| persistence.size | string | `8Gi` | Size of the data volume |
| persistence.mountPath | string | `/data` | Mount path for the data volume |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Expose the Prometheus metrics endpoint and set the auth type |
| metrics.authType | string | `public` | Metrics endpoint auth mode, public or jwt |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| tls.enabled | bool | `false` | Serve HTTPS from a mounted certificate Secret |
| tls.existingSecret | string | `""` | Secret holding the certificate and key |
| parameters | object | `{}` | Server configuration applied as MINIO_ environment variables |
