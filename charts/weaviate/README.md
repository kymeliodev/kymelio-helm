# weaviate

Weaviate vector database, deployed as a single StatefulSet with persistent
storage and anonymous access enabled by default.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-weaviate kymelio/weaviate
```

### OCI registry

```sh
helm install my-weaviate oci://ghcr.io/kymeliodev/kymelio-helm/weaviate --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-weaviate
```

The PersistentVolumeClaim is retained after uninstall. Delete it manually to
discard the data.

## Upgrading

Review the chart version change and your overridden values before upgrading.

```sh
helm upgrade my-weaviate kymelio/weaviate
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas, ignored when autoscaling is enabled |
| image.repository | string | `docker.io/semitechnologies/weaviate` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `8080` | Service port |
| service.portName | string | `http` | Service port name |
| persistence.enabled | bool | `true` | Enable a PersistentVolumeClaim |
| persistence.storageClass | string | `""` | StorageClass, empty uses the cluster default |
| persistence.size | string | `8Gi` | Size of the data volume |
| persistence.mountPath | string | `/var/lib/weaviate` | Data mount path inside the container |
| extraEnv | list | `[]` | Additional environment variables for the container |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| podDisruptionBudget.enabled | bool | `false` | Enable a PodDisruptionBudget |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| tests.image | string | `busybox:1.36` | Image used by the helm test connection check |
</content>
