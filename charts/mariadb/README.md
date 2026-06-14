# mariadb

MariaDB relational database server, deployed as a single instance StatefulSet
with persistent storage.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-mariadb kymelio/mariadb
```

### OCI registry

```sh
helm install my-mariadb oci://ghcr.io/kymeliodev/kymelio-helm/mariadb --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-mariadb
```

The PersistentVolumeClaim is retained after uninstall. Delete it manually to
discard the data.

## Upgrading

Review the chart version change and your overridden values before upgrading. A
generated password is preserved across upgrades when you keep `auth.rootPassword`
and `auth.password` empty and reuse the release Secret.

```sh
helm upgrade my-mariadb kymelio/mariadb
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas, fixed at one |
| image.repository | string | `docker.io/library/mariadb` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| auth.username | string | `mariadb` | Application user created on first start |
| auth.database | string | `mariadb` | Database created on first start |
| auth.rootPassword | string | `""` | Root password, generated when empty |
| auth.password | string | `""` | Application user password, generated when empty |
| auth.existingSecret | string | `""` | Use an existing Secret for credentials |
| auth.secretKeys.rootPasswordKey | string | `mariadb-root-password` | Secret key holding the root password |
| auth.secretKeys.passwordKey | string | `mariadb-password` | Secret key holding the application user password |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `3306` | Service port |
| persistence.enabled | bool | `true` | Enable a PersistentVolumeClaim |
| persistence.storageClass | string | `""` | StorageClass, empty uses the cluster default |
| persistence.size | string | `8Gi` | Size of the data volume |
| persistence.mountPath | string | `/var/lib/mysql` | Data directory mount path |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 999 | Pod security context |
| securityContext | object | drop ALL | Container security context |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
