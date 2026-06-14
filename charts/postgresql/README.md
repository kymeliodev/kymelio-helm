# postgresql

PostgreSQL object-relational database server, deployed as a single primary
StatefulSet with persistent storage.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-postgresql kymelio/postgresql
```

### OCI registry

```sh
helm install my-postgresql oci://ghcr.io/kymeliodev/kymelio-helm/postgresql --version 0.1.1
```

## Uninstall

```sh
helm uninstall my-postgresql
```

The PersistentVolumeClaim is retained after uninstall. Delete it manually to
discard the data.

## Upgrading

Review the chart version change and your overridden values before upgrading. A
generated password is preserved across upgrades when you keep `auth.password`
empty and reuse the release Secret.

```sh
helm upgrade my-postgresql kymelio/postgresql
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of primary replicas, fixed at one |
| image.repository | string | `docker.io/library/postgres` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| auth.username | string | `postgres` | Superuser created on first start |
| auth.database | string | `postgres` | Database created on first start |
| auth.password | string | `""` | Superuser password, generated when empty |
| auth.existingSecret | string | `""` | Use an existing Secret for credentials |
| auth.secretKeys.passwordKey | string | `postgres-password` | Secret key holding the password |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `5432` | Service port |
| persistence.enabled | bool | `true` | Enable a PersistentVolumeClaim |
| persistence.storageClass | string | `""` | StorageClass, empty uses the cluster default |
| persistence.size | string | `8Gi` | Size of the data volume |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 999 | Pod security context |
| securityContext | object | drop ALL | Container security context |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
