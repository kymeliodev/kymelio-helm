# uptime-kuma

Self hosted monitoring tool, deployed as a single StatefulSet with persistent
storage. It runs scheduled checks against your endpoints, raises notifications
and publishes status pages from a web user interface. Monitors and history are
stored on the data volume mounted at `/app/data`.

The first time you open the user interface you create the administrator account.
No credentials are required at deploy time.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-uptime-kuma kymelio/uptime-kuma
```

### OCI registry

```sh
helm install my-uptime-kuma oci://ghcr.io/kymeliodev/kymelio-helm/uptime-kuma --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-uptime-kuma
```

The PersistentVolumeClaim is retained after uninstall. Delete it manually to
discard monitors and history.

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-uptime-kuma kymelio/uptime-kuma --reuse-values
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas, single node deployment |
| image.repository | string | `docker.io/louislam/uptime-kuma` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `3001` | HTTP service port |
| service.portName | string | `http` | Named service port |
| persistence.enabled | bool | `true` | Enable a PersistentVolumeClaim |
| persistence.storageClass | string | `""` | StorageClass, empty uses the cluster default |
| persistence.size | string | `8Gi` | Size of the data volume |
| persistence.mountPath | string | `/app/data` | Data directory mount path |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |
