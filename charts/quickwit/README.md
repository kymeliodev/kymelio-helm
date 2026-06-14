# quickwit

Quickwit search engine, deployed as a single StatefulSet with persistent
storage. The chart exposes the REST API on port 7280 and the gRPC API on
port 7281.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-quickwit kymelio/quickwit
```

### OCI registry

```sh
helm install my-quickwit oci://ghcr.io/kymeliodev/kymelio-helm/quickwit --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-quickwit
```

The PersistentVolumeClaim is retained after uninstall. Delete it manually to
discard the indexed data.

## Upgrading

Review the chart version change and your overridden values before upgrading.

```sh
helm upgrade my-quickwit kymelio/quickwit
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas, ignored when autoscaling is enabled |
| image.repository | string | `docker.io/quickwit/quickwit` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| imagePullSecrets | list | `[]` | Image pull secrets for private registries |
| serviceAccount.create | bool | `true` | Create a ServiceAccount for the workload |
| serviceAccount.name | string | `""` | ServiceAccount name, generated when empty |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.http.port | int | `7280` | Primary REST API port |
| service.http.portName | string | `http` | Primary REST API port name |
| service.grpc.port | int | `7281` | gRPC API port |
| service.grpc.portName | string | `grpc` | gRPC API port name |
| ingress.enabled | bool | `false` | Create an Ingress for the REST API |
| resources | object | requests and limits | Container resource requests and limits |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| podDisruptionBudget.enabled | bool | `false` | Create a PodDisruptionBudget |
| networkPolicy.enabled | bool | `false` | Create a NetworkPolicy |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| extraEnv | list | `[]` | Extra environment variables appended to the container |
| podSecurityContext | object | runAsNonRoot 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |
| persistence.enabled | bool | `true` | Enable a PersistentVolumeClaim |
| persistence.storageClass | string | `""` | StorageClass, empty uses the cluster default |
| persistence.size | string | `8Gi` | Size of the data volume |
| persistence.mountPath | string | `/quickwit/qwdata` | Data directory mount path |
| tests.image | string | `busybox:1.36` | Image used by the helm test connection check |
