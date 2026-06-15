# vernemq

VerneMQ MQTT broker, deployed as a StatefulSet with persistent storage. The MQTT
listener is published on port 1883 and EPMD on port 4369.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-vernemq kymelio/vernemq
```

### OCI registry

```sh
helm install my-vernemq oci://ghcr.io/kymeliodev/kymelio-helm/vernemq --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-vernemq
```

The PersistentVolumeClaim is retained after uninstall. Delete it manually to
discard the data.

## Upgrading

Review the chart version change and your overridden values before upgrading.

```sh
helm upgrade my-vernemq kymelio/vernemq
```

## Notes

The broker accepts the VerneMQ EULA through the `DOCKER_VERNEMQ_ACCEPT_EULA`
environment variable and enables anonymous access through
`DOCKER_VERNEMQ_ALLOW_ANONYMOUS`. Configure authentication before exposing the
broker outside the cluster.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `docker.io/vernemq/vernemq` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.mqtt.port | int | `1883` | MQTT listener port |
| service.epmd.port | int | `4369` | EPMD port |
| persistence.enabled | bool | `true` | Enable a PersistentVolumeClaim |
| persistence.storageClass | string | `""` | StorageClass, empty uses the cluster default |
| persistence.size | string | `8Gi` | Size of the data volume |
| persistence.mountPath | string | `/vernemq/data` | Mount path for the data volume |
| resources | object | requests and limits | Container resource requests and limits |
| securityContext | object | drop ALL | Container security context |
| podSecurityContext | object | runAsNonRoot 10000 | Pod security context |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
