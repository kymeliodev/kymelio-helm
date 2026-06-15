# redpanda

Redpanda Kafka-compatible streaming data platform, deployed as a single node
StatefulSet with persistent storage.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-redpanda kymelio/redpanda
```

### OCI registry

```sh
helm install my-redpanda oci://ghcr.io/kymeliodev/kymelio-helm/redpanda --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-redpanda
```

The PersistentVolumeClaim is retained after uninstall. Delete it manually to
discard the data.

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-redpanda kymelio/redpanda
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `docker.redpanda.com/redpandadata/redpanda` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.kafka.port | int | `9092` | Kafka API service port |
| service.admin.port | int | `9644` | Admin API service port |
| persistence.enabled | bool | `true` | Enable a PersistentVolumeClaim |
| persistence.storageClass | string | `""` | StorageClass, empty uses the cluster default |
| persistence.size | string | `8Gi` | Size of the data volume |
| persistence.mountPath | string | `/var/lib/redpanda/data` | Data directory mount path |
| resources | object | requests and limits | Container resource requests and limits |
| securityContext | object | drop ALL | Container security context |
| podSecurityContext | object | runAsNonRoot 101 | Pod security context |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
