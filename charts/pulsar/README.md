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
| metrics.enabled | bool | `false` | Wire monitoring to the native Pulsar metrics endpoint on the http port |
| metrics.path | string | `/metrics` | Path the Pulsar web service serves metrics on |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| pulsarConf | object | `{}` | Native broker settings applied via PULSAR_PREFIX_ environment variables |
| tls.enabled | bool | `false` | Serve the binary protocol over TLS using native broker configuration |
| tls.existingSecret | string | `""` | Secret holding ca.crt, tls.crt and tls.key |
| tls.tlsPort | int | `6651` | TLS protocol port published when TLS is enabled |
| tls.requireTrustedClientCertOnConnect | bool | `false` | Require and verify client certificates |

## Configuration

### Metrics

Apache Pulsar exposes broker metrics in Prometheus text format on the web
service port (`8080`) under `/metrics`. No exporter sidecar is required. Enabling
metrics wires the ServiceMonitor to the http port and the metrics path:

```sh
helm install my-pulsar kymelio/pulsar \
  --set metrics.enabled=true \
  --set metrics.serviceMonitor.enabled=true
```

### Broker tuning

Pass native broker settings through `pulsarConf`. Each key/value pair is applied
as a `PULSAR_PREFIX_<key>` environment variable, which the image entrypoint
writes into the broker configuration before start:

```yaml
pulsarConf:
  maxMessageSize: "10485760"
  numIOThreads: "8"
  managedLedgerDefaultEnsembleSize: "1"
```

The generic `configuration` surface remains available for mounting a full
config file at `configMountPath` when you prefer to manage `broker.conf`
yourself.

### TLS

Pulsar enables TLS through its native broker configuration. Provide a Secret
with `ca.crt`, `tls.crt` and `tls.key`; the chart mounts it, sets the matching
`tls*` broker settings through `PULSAR_PREFIX_` variables and publishes the TLS
protocol listener on `tls.tlsPort`:

```sh
helm install my-pulsar kymelio/pulsar \
  --set tls.enabled=true \
  --set tls.existingSecret=pulsar-tls \
  --set tls.requireTrustedClientCertOnConnect=true
```
