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
| metrics.enabled | bool | `false` | Enable JMX on the broker and add the JMX exporter sidecar |
| metrics.path | string | `/metrics` | Path the exporter serves metrics on |
| metrics.jmxPort | int | `1099` | JMX port the broker exposes for the sidecar |
| metrics.image.repository | string | `docker.io/sscaling/jmx-prometheus-exporter` | JMX exporter sidecar image |
| metrics.image.tag | string | `0.20.0` | JMX exporter sidecar image tag |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| service.metrics.port | int | `5556` | Exporter metrics service port |
| configuration | string | `""` | Inline activemq.xml rendered into a ConfigMap and mounted |
| configMountPath | string | `/config` | Mount path for the configuration |
| configSubPath | string | `""` | Mount the configuration as a single file using subPath |

## Configuration

### Metrics

ActiveMQ Classic has no native Prometheus endpoint. This chart collects metrics
with a community JMX exporter sidecar (`sscaling/jmx-prometheus-exporter`, not
the bitnami image) that reads the broker over JMX and serves Prometheus text
format on port `5556` under `/metrics`. Enabling metrics turns on remote JMX on
the broker, renders the exporter config ConfigMap, adds the sidecar and
publishes the metrics port:

```sh
helm install my-activemq kymelio/activemq \
  --set metrics.enabled=true \
  --set metrics.serviceMonitor.enabled=true
```

### Broker tuning

Native ActiveMQ tuning is done through `activemq.xml`. Provide it inline through
the generic `configuration` surface and mount it over the broker configuration
directory:

```yaml
configuration: |
  <beans xmlns="http://www.springframework.org/schema/beans">
    <broker xmlns="http://activemq.apache.org/schema/core" brokerName="broker">
      <systemUsage>
        <systemUsage>
          <memoryUsage><memoryUsage percentOfJvmHeap="70"/></memoryUsage>
        </systemUsage>
      </systemUsage>
    </broker>
  </beans>
configFileName: activemq.xml
configMountPath: /opt/apache-activemq/conf
configSubPath: activemq.xml
```

Use an `existingConfigMap` instead when you manage the configuration outside the
chart.
