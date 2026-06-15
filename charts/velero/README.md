# velero

Deploys the Velero server, which performs backup, restore, disaster recovery
and migration of Kubernetes cluster resources and persistent volumes.

This chart installs the server as a Deployment together with its ServiceAccount
and cluster scoped RBAC. Velero requires additional configuration to be usable:

- An object storage backend (for example AWS S3, Google Cloud Storage or Azure
  Blob Storage, or an S3 compatible store such as MinIO) where backups are
  stored.
- One or more provider plugins that integrate Velero with that backend and with
  the volume snapshot APIs of your environment.
- The Velero Custom Resource Definitions, which are installed separately and
  must be present before the server starts processing backups and restores.

Provide the backend credentials and a BackupStorageLocation, configure the
relevant VolumeSnapshotLocation, and add the matching plugins for your
environment after installing this chart.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-velero kymelio/velero
```

### OCI registry

```sh
helm install my-velero oci://ghcr.io/kymeliodev/kymelio-helm/velero --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-velero
```

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-velero kymelio/velero --reuse-values
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of server replicas |
| image.repository | string | `docker.io/velero/velero` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| command | list | `["/velero"]` | Container entrypoint |
| args | list | `["server"]` | Arguments passed to the server |
| serviceAccount.create | bool | `true` | Create a ServiceAccount for the server |
| rbac.create | bool | `true` | Create the ClusterRole and ClusterRoleBinding |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `8085` | Metrics port, named metrics |
| podSecurityContext | object | runAsNonRoot 65534 | Pod security context |
| securityContext | object | drop ALL | Container security context |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
