# cassandra

Apache Cassandra wide-column database, deployed as a single node StatefulSet
with persistent storage.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-cassandra kymelio/cassandra
```

### OCI registry

```sh
helm install my-cassandra oci://ghcr.io/kymeliodev/kymelio-helm/cassandra --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-cassandra
```

The PersistentVolumeClaim is retained after uninstall. Delete it manually to
discard the data.

## Upgrading

Review the chart version change and your overridden values before upgrading.

```sh
helm upgrade my-cassandra kymelio/cassandra
```

## Configuration

### Metrics

Cassandra has no built-in Prometheus endpoint, so metrics are exposed through a
jmx_exporter sidecar that reads MBeans over the local JMX port and serves them on
`metrics.port` at `/metrics`. Enabling metrics also opens JMX inside the pod and
adds a `metrics` port to the Service.

```yaml
metrics:
  enabled: true
  serviceMonitor:
    enabled: true
```

Tune which MBeans are scraped through `metrics.config`, which is rendered into the
exporter ConfigMap:

```yaml
metrics:
  enabled: true
  config:
    lowercaseOutputName: true
    rules:
      - pattern: "org.apache.cassandra.metrics<type=(\\w+), name=(\\w+)><>Value"
        name: cassandra_$1_$2
```

### Config tuning

Set native `cassandra.yaml` settings through `cassandra.configFragment`. The
fragment is rendered into a ConfigMap and mounted at
`cassandra.configFragmentMountPath`.

```yaml
cassandra:
  configFragment: |
    concurrent_reads: 64
    concurrent_writes: 64
    compaction_throughput_mb_per_sec: 32
```

The generic `configuration` value remains available for mounting an arbitrary
config file.

### TLS

Client (CQL) encryption is configured through the `cassandra.yaml` fragment. Provide
a Secret holding the keystore and truststore and enable `tls`:

```sh
helm install my-cassandra kymelio/cassandra \
  --set tls.enabled=true \
  --set tls.existingSecret=cassandra-tls \
  --set tls.keystorePassword=changeit \
  --set tls.truststorePassword=changeit
```

The Secret is mounted read only at `tls.mountPath` and the chart writes the matching
`client_encryption_options` block into the rendered `cassandra.yaml`.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas, fixed at one |
| image.repository | string | `docker.io/library/cassandra` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| cassandra.clusterName | string | `cassandra-cluster` | Cassandra cluster name |
| cassandra.datacenter | string | `datacenter1` | Local datacenter name |
| cassandra.endpointSnitch | string | `GossipingPropertyFileSnitch` | Endpoint snitch strategy |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `9042` | CQL service port |
| persistence.enabled | bool | `true` | Enable a PersistentVolumeClaim |
| persistence.storageClass | string | `""` | StorageClass, empty uses the cluster default |
| persistence.size | string | `8Gi` | Size of the data volume |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 999 | Pod security context |
| securityContext | object | drop ALL | Container security context |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Run a jmx_exporter sidecar exposing Prometheus metrics |
| metrics.image.repository | string | `docker.io/sscaling/jmx-prometheus-exporter` | Exporter sidecar image repository |
| metrics.port | int | `5556` | Port the exporter sidecar listens on |
| metrics.config | object | scrape all MBeans | jmx_exporter rules rendered into a ConfigMap |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| cassandra.configFragment | string | `""` | Native cassandra.yaml fragment mounted into the pod |
| tls.enabled | bool | `false` | Enable client TLS via cassandra.yaml client_encryption_options |
| tls.existingSecret | string | `""` | Secret holding the keystore and truststore |
| tls.keystorePassword | string | `""` | Keystore password written into cassandra.yaml |
| tls.truststorePassword | string | `""` | Truststore password written into cassandra.yaml |
