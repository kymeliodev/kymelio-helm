# mosquitto

Eclipse Mosquitto MQTT broker, deployed as a single StatefulSet with persistent
storage. The chart ships a bundled `mosquitto.conf` that opens an MQTT listener
on port 1883, enables on-disk persistence, and allows anonymous access by
default.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-mosquitto kymelio/mosquitto
```

### OCI registry

```sh
helm install my-mosquitto oci://ghcr.io/kymeliodev/kymelio-helm/mosquitto --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-mosquitto
```

The PersistentVolumeClaim is retained after uninstall. Delete it manually to
discard the data.

## Upgrading

Review the chart version change and your overridden values before upgrading.

```sh
helm upgrade my-mosquitto kymelio/mosquitto
```

## Configuration

The chart renders a ConfigMap holding `mosquitto.conf` and mounts it read-only
at `/mosquitto/config/mosquitto.conf`. The bundled file allows anonymous access,
which is convenient for local use but should be replaced with authentication
before exposing the broker on an untrusted network.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `docker.io/library/eclipse-mosquitto` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `1883` | MQTT listener port |
| persistence.enabled | bool | `true` | Enable a PersistentVolumeClaim |
| persistence.storageClass | string | `""` | StorageClass, empty uses the cluster default |
| persistence.size | string | `8Gi` | Size of the data volume |
| persistence.mountPath | string | `/mosquitto/data` | Mount path for the data volume |
| resources | object | requests and limits | Container resource requests and limits |
| securityContext | object | drop ALL | Container security context |
| podSecurityContext | object | runAsNonRoot 1883 | Pod security context |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
