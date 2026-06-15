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
| metrics.enabled | bool | `false` | Publish the Prometheus extension port and wire monitoring to it |
| metrics.port | int | `9399` | Port the HiveMQ Prometheus extension listens on |
| metrics.path | string | `/metrics` | Path the extension serves metrics on |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| service.metrics.port | int | `9399` | Prometheus extension service port |
| configuration | string | `""` | Inline config.xml rendered into a ConfigMap and mounted |
| configMountPath | string | `/config` | Mount path for the configuration |
| configSubPath | string | `""` | Mount the configuration as a single file using subPath |

## Configuration

### Metrics

HiveMQ Community Edition has no built in Prometheus endpoint. Metrics require the
official [HiveMQ Prometheus extension](https://github.com/hivemq/hivemq-prometheus-extension),
which exposes metrics on port `9399` under `/metrics`. The stock
`hivemq/hivemq-ce` image does not ship the extension enabled, so it must be
present in the image before any metrics are scraped. Build an image that adds and
enables the extension, for example:

```dockerfile
FROM hivemq/hivemq-ce:2024.7
ADD --chown=10000:0 \
  https://github.com/hivemq/hivemq-prometheus-extension/releases/latest/download/hivemq-prometheus-extension.zip \
  /opt/hivemq/extensions/
RUN cd /opt/hivemq/extensions && unzip hivemq-prometheus-extension.zip && \
  rm hivemq-prometheus-extension.zip
```

The extension reads `prometheusConfiguration.properties` (defaults: `port=9399`,
`metric_path=/metrics`, `host=0.0.0.0`). Once the image carries the extension,
enable the chart side wiring so the port is published and scraped:

```sh
helm install my-hivemq kymelio/hivemq \
  --set image.repository=registry.example.com/hivemq-ce-prometheus \
  --set metrics.enabled=true \
  --set metrics.serviceMonitor.enabled=true
```

### Broker tuning

Native HiveMQ tuning is done through `config.xml`. Provide it inline through the
generic `configuration` surface and mount it over the HiveMQ configuration
directory:

```yaml
configuration: |
  <hivemq>
    <listeners>
      <tcp-listener>
        <port>1883</port>
        <bind-address>0.0.0.0</bind-address>
      </tcp-listener>
    </listeners>
    <mqtt>
      <queued-messages>
        <max-queue-size>1000</max-queue-size>
      </queued-messages>
    </mqtt>
  </hivemq>
configFileName: config.xml
configMountPath: /opt/hivemq/conf
configSubPath: config.xml
```

A TLS MQTT listener is configured the same way, by adding a `<tls-tcp-listener>`
with a `<keystore>` element to the `config.xml` and mounting the keystore through
`extraVolumes` / `extraVolumeMounts`.
