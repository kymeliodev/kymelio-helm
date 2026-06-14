# cassandra

Apache Cassandra wide-column database, deployed as a single node StatefulSet
with persistent storage.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-cassandra kymelio/cassandra
```

### OCI registry

```sh
helm install my-cassandra oci://ghcr.io/kymeliodev/kymelio-helm/cassandra --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-cassandra
```

The PersistentVolumeClaim is retained after uninstall. Delete it manually to
discard the data.

## Upgrading

Review the chart version change and your overridden values before upgrading.

```sh
helm upgrade my-cassandra kymelio/cassandra
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas, fixed at one |
| image.repository | string | `docker.io/library/cassandra` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| cassandra.clusterName | string | `cassandra-cluster` | Cassandra cluster name |
| cassandra.datacenter | string | `datacenter1` | Local datacenter name |
| cassandra.endpointSnitch | string | `GossipingPropertyFileSnitch` | Endpoint snitch strategy |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `9042` | CQL service port |
| persistence.enabled | bool | `true` | Enable a PersistentVolumeClaim |
| persistence.storageClass | string | `""` | StorageClass, empty uses the cluster default |
| persistence.size | string | `8Gi` | Size of the data volume |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 999 | Pod security context |
| securityContext | object | drop ALL | Container security context |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
