# meilisearch

Meilisearch search engine, deployed as a single StatefulSet with persistent
storage and master key authentication.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-meilisearch kymelio/meilisearch
```

### OCI registry

```sh
helm install my-meilisearch oci://ghcr.io/kymeliodev/kymelio-helm/meilisearch --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-meilisearch
```

The PersistentVolumeClaim is retained after uninstall. Delete it manually to
discard the data.

## Upgrading

Review the chart version change and your overridden values before upgrading. A
generated master key is preserved across upgrades when you keep `auth.masterKey`
empty and reuse the release Secret.

```sh
helm upgrade my-meilisearch kymelio/meilisearch
```

## Configuration

### Metrics

Meilisearch ships a built in Prometheus endpoint at `/metrics` on the HTTP port.
Setting `metrics.enabled=true` sets `MEILI_EXPERIMENTAL_ENABLE_METRICS=true`. The
ServiceMonitor scrapes the HTTP port at that path. The endpoint requires the master
key, so configure scrape authorization with a bearer token.

```sh
helm install my-meilisearch kymelio/meilisearch \
  --set metrics.enabled=true \
  --set metrics.serviceMonitor.enabled=true
```

### TLS

Meilisearch terminates TLS natively. Set `tls.enabled=true` and provide a Secret;
the chart mounts it and points `MEILI_SSL_CERT_PATH` and `MEILI_SSL_KEY_PATH` at
the mounted files.

```sh
helm install my-meilisearch kymelio/meilisearch \
  --set tls.enabled=true \
  --set tls.existingSecret=meilisearch-tls
```

Additional launch options such as a config file are passed through `extraEnv`
(for example `MEILI_CONFIG_FILE_PATH`) or `extraArgs`.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas |
| image.repository | string | `docker.io/getmeili/meilisearch` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| auth.masterKey | string | `""` | Master key, generated when empty |
| auth.existingSecret | string | `""` | Use an existing Secret for the master key |
| auth.secretKeys.masterKeyKey | string | `master-key` | Secret key holding the master key |
| meiliEnv | string | `production` | Operating mode passed to MEILI_ENV |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `7700` | Service port |
| persistence.enabled | bool | `true` | Enable a PersistentVolumeClaim |
| persistence.storageClass | string | `""` | StorageClass, empty uses the cluster default |
| persistence.size | string | `8Gi` | Size of the data volume |
| persistence.mountPath | string | `/meili_data` | Data directory mount path |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Enable the built in Prometheus endpoint via MEILI_EXPERIMENTAL_ENABLE_METRICS |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| metrics.serviceMonitor.path | string | `/metrics` | Path the endpoint is scraped on |
| tls.enabled | bool | `false` | Terminate TLS natively with a mounted certificate Secret |
| tls.existingSecret | string | `""` | Secret holding the certificate and key |
| tls.certFilename | string | `tls.crt` | Certificate file name in the Secret |
| tls.keyFilename | string | `tls.key` | Private key file name in the Secret |
