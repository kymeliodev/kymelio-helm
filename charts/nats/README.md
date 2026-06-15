# nats

NATS server with JetStream enabled, deployed as a single node StatefulSet with
persistent storage for the JetStream store directory.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-nats kymelio/nats
```

### OCI registry

```sh
helm install my-nats oci://ghcr.io/kymeliodev/kymelio-helm/nats --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-nats
```

The PersistentVolumeClaim is retained after uninstall. Delete it manually to
discard the JetStream data.

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-nats kymelio/nats
```

## Values

JetStream is enabled by default with the store directory set to `/data`.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `docker.io/library/nats` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.client.port | int | `4222` | Client port |
| service.http.port | int | `8222` | Monitoring HTTP port |
| persistence.enabled | bool | `true` | Enable a PersistentVolumeClaim |
| persistence.storageClass | string | `""` | StorageClass, empty uses the cluster default |
| persistence.size | string | `8Gi` | Size of the JetStream data volume |
| persistence.mountPath | string | `/data` | JetStream store directory mount path |
| resources | object | requests and limits | Container resource requests and limits |
| securityContext | object | drop ALL | Container security context |
| podSecurityContext | object | runAsNonRoot 1000 | Pod security context |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
