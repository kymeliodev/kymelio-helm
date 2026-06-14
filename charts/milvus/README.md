# milvus

Milvus vector database, deployed in standalone mode as a single StatefulSet
with persistent storage. Embedded etcd and local object storage are enabled so
the chart runs without external dependencies.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-milvus kymelio/milvus
```

### OCI registry

```sh
helm install my-milvus oci://ghcr.io/kymeliodev/kymelio-helm/milvus --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-milvus
```

The PersistentVolumeClaim is retained after uninstall. Delete it manually to
discard the data.

## Ports

The Service and the StatefulSet container publish two ports:

| Name | Port | Purpose |
|------|------|---------|
| grpc | 19530 | Primary gRPC API used by clients |
| http | 9091 | HTTP health (`/healthz`) and metrics endpoint |

The liveness and readiness probes call `/healthz` on the http port. The bundled
connection test and the primary client connection use the grpc port 19530.

## Upgrading

Review the chart version change and your overridden values before upgrading.

```sh
helm upgrade my-milvus kymelio/milvus
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas, fixed at one in standalone mode |
| image.repository | string | `docker.io/milvusdb/milvus` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.grpc.port | int | `19530` | Primary gRPC API port |
| service.grpc.portName | string | `grpc` | Name of the gRPC port |
| service.http.port | int | `9091` | HTTP health and metrics port |
| service.http.portName | string | `http` | Name of the HTTP port |
| service.exposedPorts | list | grpc and http | Ports published on the Service and container |
| persistence.enabled | bool | `true` | Enable a PersistentVolumeClaim |
| persistence.storageClass | string | `""` | StorageClass, empty uses the cluster default |
| persistence.size | string | `8Gi` | Size of the data volume |
| persistence.mountPath | string | `/var/lib/milvus` | Data mount path inside the container |
| extraEnv | list | `[]` | Extra environment variables appended to the container |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |
| ingress.enabled | bool | `false` | Enable an Ingress for the gRPC API |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| podDisruptionBudget.enabled | bool | `false` | Enable a PodDisruptionBudget |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor scraping the http port |
