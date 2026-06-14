# activemq

Apache ActiveMQ Classic message broker, deployed as a single node StatefulSet
with persistent storage. The OpenWire protocol port and the web console are
both published.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-activemq kymelio/activemq
```

### OCI registry

```sh
helm install my-activemq oci://ghcr.io/kymeliodev/kymelio-helm/activemq --version 0.1.0
```

The broker ships with default credentials for the web console and broker login,
username `admin` and password `admin`.

## Uninstall

```sh
helm uninstall my-activemq
```

The PersistentVolumeClaim is retained after uninstall. Delete it manually to
discard the data.

## Upgrading

Review the chart version change and your overridden values before upgrading.

```sh
helm upgrade my-activemq kymelio/activemq
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas, ignored when autoscaling is enabled |
| image.repository | string | `docker.io/apache/activemq-classic` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.openwire.port | int | `61616` | OpenWire protocol port |
| service.web.port | int | `8161` | Web console port |
| persistence.enabled | bool | `true` | Enable a PersistentVolumeClaim |
| persistence.storageClass | string | `""` | StorageClass, empty uses the cluster default |
| persistence.size | string | `8Gi` | Size of the data volume |
| persistence.mountPath | string | `/opt/apache-activemq/data` | Broker data directory mount path |
| resources | object | requests and limits | Container resource requests and limits |
| securityContext | object | drop ALL | Container security context |
| podSecurityContext | object | runAsNonRoot 1000 | Pod security context |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
