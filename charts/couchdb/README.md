# couchdb

Apache CouchDB document database, deployed as a single StatefulSet with
persistent storage.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-couchdb kymelio/couchdb
```

### OCI registry

```sh
helm install my-couchdb oci://ghcr.io/kymeliodev/kymelio-helm/couchdb --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-couchdb
```

The PersistentVolumeClaim is retained after uninstall. Delete it manually to
discard the data.

## Upgrading

Review the chart version change and your overridden values before upgrading. A
generated password is preserved across upgrades when you keep `auth.password`
empty and reuse the release Secret.

```sh
helm upgrade my-couchdb kymelio/couchdb
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `docker.io/library/couchdb` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| auth.username | string | `admin` | Admin user created on first start |
| auth.password | string | `""` | Admin password, generated when empty |
| auth.existingSecret | string | `""` | Use an existing Secret for credentials |
| auth.secretKeys.passwordKey | string | `couchdb-password` | Secret key holding the password |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `5984` | Service port |
| persistence.enabled | bool | `true` | Enable a PersistentVolumeClaim |
| persistence.storageClass | string | `""` | StorageClass, empty uses the cluster default |
| persistence.size | string | `8Gi` | Size of the data volume |
| persistence.mountPath | string | `/opt/couchdb/data` | Path where the data volume is mounted |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 5984 | Pod security context |
| securityContext | object | drop ALL | Container security context |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
