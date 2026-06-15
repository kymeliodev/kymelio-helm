# questdb

QuestDB high performance time series database, deployed as a single
StatefulSet with persistent storage. The chart exposes the http web console
and REST API alongside the PostgreSQL wire protocol.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-questdb kymelio/questdb
```

### OCI registry

```sh
helm install my-questdb oci://ghcr.io/kymeliodev/kymelio-helm/questdb --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-questdb
```

The PersistentVolumeClaim is retained after uninstall. Delete it manually to
discard the data.

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-questdb kymelio/questdb
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas, fixed at one |
| image.repository | string | `docker.io/questdb/questdb` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.ports.http | int | `9000` | Web console and REST API port |
| service.ports.postgres | int | `8812` | PostgreSQL wire protocol port |
| service.primaryPortName | string | `http` | Port used by probes, NOTES and the test |
| persistence.enabled | bool | `true` | Enable a PersistentVolumeClaim |
| persistence.storageClass | string | `""` | StorageClass, empty uses the cluster default |
| persistence.size | string | `8Gi` | Size of the data volume |
| persistence.mountPath | string | `/var/lib/questdb` | Mount path for the data volume |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 10001 | Pod security context |
| securityContext | object | drop ALL | Container security context |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
