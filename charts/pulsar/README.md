# pulsar

Apache Pulsar messaging and streaming platform, deployed as a single
StatefulSet running in standalone mode with persistent storage. The standalone
process bundles the broker, bookie and ZooKeeper in one container and is
intended for development and testing rather than production clustering.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-pulsar kymelio/pulsar
```

### OCI registry

```sh
helm install my-pulsar oci://ghcr.io/kymeliodev/kymelio-helm/pulsar --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-pulsar
```

The PersistentVolumeClaim is retained after uninstall. Delete it manually to
discard the data.

## Upgrading

Review the chart version change and your overridden values before upgrading.

```sh
helm upgrade my-pulsar kymelio/pulsar
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `docker.io/apachepulsar/pulsar` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.pulsar.port | int | `6650` | Pulsar binary protocol port |
| service.http.port | int | `8080` | HTTP admin and REST API port |
| persistence.enabled | bool | `true` | Enable a PersistentVolumeClaim |
| persistence.storageClass | string | `""` | StorageClass, empty uses the cluster default |
| persistence.size | string | `8Gi` | Size of the data volume |
| persistence.mountPath | string | `/pulsar/data` | Mount path for the data volume |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 10000 | Pod security context |
| securityContext | object | drop ALL | Container security context |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
