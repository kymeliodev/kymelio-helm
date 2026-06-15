# hivemq

HiveMQ Community Edition MQTT broker, deployed as a single node StatefulSet
with persistent storage. The MQTT listener and the HTTP control center are
published as separate Service ports.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-hivemq kymelio/hivemq
```

### OCI registry

```sh
helm install my-hivemq oci://ghcr.io/kymeliodev/kymelio-helm/hivemq --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-hivemq
```

The PersistentVolumeClaim is retained after uninstall. Delete it manually to
discard the data.

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-hivemq kymelio/hivemq --reuse-values
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `docker.io/hivemq/hivemq-ce` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.mqtt.port | int | `1883` | MQTT listener port |
| service.http.port | int | `8080` | HTTP control center port |
| persistence.enabled | bool | `true` | Enable a PersistentVolumeClaim |
| persistence.storageClass | string | `""` | StorageClass, empty uses the cluster default |
| persistence.size | string | `8Gi` | Size of the data volume |
| persistence.mountPath | string | `/opt/hivemq/data` | Mount path for the data volume |
| resources | object | requests and limits | Container resource requests and limits |
| securityContext | object | drop ALL | Container security context |
| podSecurityContext | object | runAsNonRoot 10000 | Pod security context |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
