# victoriametrics

Fast and cost effective time series database, deployed as a single node
StatefulSet with persistent storage. It ingests Prometheus style metrics and
serves PromQL and MetricsQL queries over HTTP.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-victoriametrics kymelio/victoriametrics
```

### OCI registry

```sh
helm install my-victoriametrics oci://ghcr.io/kymeliodev/kymelio-helm/victoriametrics --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-victoriametrics
```

The PersistentVolumeClaim is retained after uninstall. Delete it manually to
discard the stored metrics.

## Upgrading

Review the chart version change and your overridden values before upgrading.

```sh
helm upgrade my-victoriametrics kymelio/victoriametrics --reuse-values
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas, single node deployment |
| image.repository | string | `docker.io/victoriametrics/victoria-metrics` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| args | list | storageDataPath and httpListenAddr | Command line flags for the binary |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `8428` | HTTP service port |
| service.portName | string | `http` | Named service port |
| persistence.enabled | bool | `true` | Enable a PersistentVolumeClaim |
| persistence.storageClass | string | `""` | StorageClass, empty uses the cluster default |
| persistence.size | string | `8Gi` | Size of the data volume |
| persistence.mountPath | string | `/victoria-metrics-data` | Data directory mount path |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
