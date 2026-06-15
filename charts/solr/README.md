# solr

Apache Solr search platform, deployed as a StatefulSet with persistent storage
and a single HTTP endpoint on port 8983.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-solr kymelio/solr
```

### OCI registry

```sh
helm install my-solr oci://ghcr.io/kymeliodev/kymelio-helm/solr --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-solr
```

The PersistentVolumeClaim is retained after uninstall. Delete it manually to
discard the index data.

## Upgrading

Review the chart version change and your overridden values before upgrading.

```sh
helm upgrade my-solr kymelio/solr
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas, ignored when autoscaling is enabled |
| image.repository | string | `docker.io/library/solr` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `8983` | Service port |
| service.portName | string | `http` | Service and container port name |
| persistence.enabled | bool | `true` | Enable a PersistentVolumeClaim |
| persistence.storageClass | string | `""` | StorageClass, empty uses the cluster default |
| persistence.size | string | `8Gi` | Size of the data volume |
| persistence.mountPath | string | `/var/solr` | Mount path for the Solr home directory |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsUser 8983 | Pod security context, runs as the solr user |
| securityContext | object | drop ALL | Container security context |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| podDisruptionBudget.enabled | bool | `false` | Enable a PodDisruptionBudget |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| extraEnv | list | `[]` | Extra environment variables for the container |
| tests.image | string | `busybox:1.36` | Image used by the helm test connection check |
