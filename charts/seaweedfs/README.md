# seaweedfs

Deploys SeaweedFS, a fast distributed object and file storage system. This
chart runs the combined `weed server` process as a StatefulSet, starting the
master, volume and filer components in a single pod and persisting their data
under `/data`.

The pod publishes three ports:

| Component | Port | Name |
|-----------|------|------|
| master | 9333 | master |
| volume | 8080 | volume |
| filer | 8888 | filer |

Data is stored on a PersistentVolumeClaim mounted at `/data`. The combined
server is convenient for single node and development setups. For production you
typically separate the master, volume and filer roles across dedicated
StatefulSets.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-seaweedfs kymelio/seaweedfs
```

### OCI registry

```sh
helm install my-seaweedfs oci://ghcr.io/kymeliodev/kymelio-helm/seaweedfs --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-seaweedfs
```

The PersistentVolumeClaim is retained after uninstall. Delete it manually to
discard the data.

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-seaweedfs kymelio/seaweedfs --reuse-values
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas |
| image.repository | string | `docker.io/chrislusf/seaweedfs` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| command | list | `["weed"]` | Container entrypoint |
| args | list | combined server args | Arguments passed to the server |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `9333` | Primary master port used by probes and ingress |
| service.portName | string | `master` | Name of the primary port |
| service.ports | list | master, volume, filer | All ports published by the server |
| persistence.enabled | bool | `true` | Enable a PersistentVolumeClaim |
| persistence.storageClass | string | `""` | StorageClass, empty uses the cluster default |
| persistence.size | string | `8Gi` | Size of the data volume |
| persistence.mountPath | string | `/data` | Data directory mount path |
| podSecurityContext | object | runAsNonRoot 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
