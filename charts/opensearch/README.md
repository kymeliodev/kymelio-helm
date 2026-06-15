# opensearch

OpenSearch search and analytics engine, deployed as a single node StatefulSet
with persistent storage. The security plugin is disabled, so the REST API is
served over plain HTTP without authentication.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-opensearch kymelio/opensearch
```

### OCI registry

```sh
helm install my-opensearch oci://ghcr.io/kymeliodev/kymelio-helm/opensearch --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-opensearch
```

The PersistentVolumeClaim is retained after uninstall. Delete it manually to
discard the data.

## Upgrading

Review the chart version change and your overridden values before upgrading.

```sh
helm upgrade my-opensearch kymelio/opensearch
```

## Ports

The workload exposes two ports. The HTTP port serves the REST API and the
transport port is used for node to node communication.

| Name | Port | Purpose |
|------|------|---------|
| http | 9200 | REST API |
| transport | 9300 | Node to node transport |

## Configuration

### Metrics

OpenSearch exposes no Prometheus HTTP endpoint in this single-node configuration.
Setting `metrics.enabled=true` runs a community `elasticsearch_exporter` sidecar,
which is compatible with OpenSearch, on port 9114 at `/metrics`. The exporter port
is added to the Service and the ServiceMonitor switches to it when both flags are on.

```sh
helm install my-opensearch kymelio/opensearch \
  --set metrics.enabled=true \
  --set metrics.serviceMonitor.enabled=true
```

### Native configuration

Use `opensearchConfig` to supply an `opensearch.yml`, mounted over the image
default, alongside the generic `configuration` surface.

```yaml
opensearchConfig: |
  cluster.name: search-cluster
  bootstrap.memory_lock: true
```

### TLS

OpenSearch HTTP TLS is provided by the security plugin and configured through
`plugins.security.ssl.http.*` in `opensearch.yml`. Set `tls.enabled=true` to mount
a certificate Secret, then enable the security plugin and reference the files from
`opensearchConfig`.

```yaml
tls:
  enabled: true
  existingSecret: opensearch-http-tls
opensearchConfig: |
  plugins.security.ssl.http.enabled: true
  plugins.security.ssl.http.pemcert_filepath: certs/tls.crt
  plugins.security.ssl.http.pemkey_filepath: certs/tls.key
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas. Ignored when autoscaling is enabled |
| image.repository | string | `docker.io/opensearchproject/opensearch` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.http.port | int | `9200` | HTTP REST API port |
| service.http.portName | string | `http` | HTTP port name |
| service.transport.port | int | `9300` | Node to node transport port |
| service.transport.portName | string | `transport` | Transport port name |
| persistence.enabled | bool | `true` | Enable a PersistentVolumeClaim |
| persistence.storageClass | string | `""` | StorageClass, empty uses the cluster default |
| persistence.size | string | `8Gi` | Size of the data volume |
| persistence.mountPath | string | `/usr/share/opensearch/data` | Data mount path |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |
| extraEnv | list | `[]` | Extra environment variables appended to the container |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Run an elasticsearch_exporter sidecar exposing metrics |
| metrics.image.repository | string | `quay.io/prometheuscommunity/elasticsearch-exporter` | Exporter image repository |
| metrics.image.tag | string | `v1.7.0` | Exporter image tag |
| metrics.port | int | `9114` | Exporter listen and Service port |
| metrics.esUri | string | `http://127.0.0.1:9200` | URI the exporter scrapes |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| opensearchConfig | string | `""` | Native opensearch.yml contents, mounted over the default |
| tls.enabled | bool | `false` | Mount a certificate Secret for HTTP TLS |
| tls.existingSecret | string | `""` | Secret holding the certificate and key |
| tls.certFilename | string | `tls.crt` | Certificate file name in the Secret |
| tls.keyFilename | string | `tls.key` | Private key file name in the Secret |
