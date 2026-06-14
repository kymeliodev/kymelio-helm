# typesense

Typesense typo-tolerant search engine, deployed as a single StatefulSet with
persistent storage.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-typesense kymelio/typesense
```

### OCI registry

```sh
helm install my-typesense oci://ghcr.io/kymeliodev/kymelio-helm/typesense --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-typesense
```

The PersistentVolumeClaim is retained after uninstall. Delete it manually to
discard the data.

## Upgrading

Review the chart version change and your overridden values before upgrading. A
generated API key is preserved across upgrades when you keep `auth.apiKey`
empty and reuse the release Secret.

```sh
helm upgrade my-typesense kymelio/typesense
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas |
| image.repository | string | `docker.io/typesense/typesense` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| auth.apiKey | string | `""` | Bootstrap API key, generated when empty |
| auth.existingSecret | string | `""` | Use an existing Secret for the API key |
| auth.secretKeys.apiKeyKey | string | `api-key` | Secret key holding the API key |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `8108` | Service port |
| persistence.enabled | bool | `true` | Enable a PersistentVolumeClaim |
| persistence.storageClass | string | `""` | StorageClass, empty uses the cluster default |
| persistence.size | string | `8Gi` | Size of the data volume |
| persistence.mountPath | string | `/data` | Data directory mount path |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
