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
| metrics.enabled | bool | `false` | Add the mosquitto-exporter sidecar and publish its port |
| metrics.image.repository | string | `sapcc/mosquitto-exporter` | Exporter sidecar image |
| metrics.image.tag | string | `0.8.0` | Exporter sidecar image tag |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| service.metrics.port | int | `9234` | Exporter metrics service port |
| mosquittoConf | string | listener 1883 | Broker configuration rendered into mosquitto.conf |

## Configuration

### Metrics

Mosquitto has no native Prometheus endpoint, it publishes broker statistics on
the `$SYS` topics instead. The community `sapcc/mosquitto-exporter` sidecar
subscribes to those topics over MQTT and re-exposes them as Prometheus metrics
on its own port (`9234`). Enabling metrics adds the sidecar, publishes its port
and wires the ServiceMonitor to it.

```sh
helm install my-mosquitto kymelio/mosquitto \
  --set metrics.enabled=true \
  --set metrics.serviceMonitor.enabled=true
```

### Broker configuration

The broker is tuned through `mosquittoConf`, which is rendered into
`mosquitto.conf` and mounted into the container. Override it to change listeners,
persistence or access control:

```yaml
mosquittoConf: |-
  listener 1883
  allow_anonymous false
  password_file /mosquitto/config/passwd
  persistence true
  persistence_location /mosquitto/data/
  max_inflight_messages 40
```

### TLS

Mosquitto enables TLS natively through `mosquitto.conf`. Mount the certificate
files with `extraVolumes`/`extraVolumeMounts` and reference them from a TLS
listener in `mosquittoConf`:

```yaml
extraVolumes:
  - name: certs
    secret:
      secretName: mosquitto-tls
extraVolumeMounts:
  - name: certs
    mountPath: /mosquitto/certs
    readOnly: true
mosquittoConf: |-
  listener 1883
  listener 8883
  cafile /mosquitto/certs/ca.crt
  certfile /mosquitto/certs/tls.crt
  keyfile /mosquitto/certs/tls.key
  require_certificate false
  persistence true
  persistence_location /mosquitto/data/
```
