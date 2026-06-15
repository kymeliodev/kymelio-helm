# elasticsearch

Elasticsearch search and analytics engine, deployed as a single-node
StatefulSet with persistent storage. X-Pack security is disabled, so the HTTP
API is reachable without credentials.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-elasticsearch kymelio/elasticsearch
```

### OCI registry

```sh
helm install my-elasticsearch oci://ghcr.io/kymeliodev/kymelio-helm/elasticsearch --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-elasticsearch
```

The PersistentVolumeClaim is retained after uninstall. Delete it manually to
discard the data.

## Upgrading

Review the chart version change and your overridden values before upgrading.

```sh
helm upgrade my-elasticsearch kymelio/elasticsearch
```

## Connecting

The HTTP API listens on port 9200 and the node transport on port 9300. Inside
the cluster reach the API at:

```
http://<release>-elasticsearch.<namespace>.svc.cluster.local:9200
```

Check cluster health:

```sh
kubectl --namespace <namespace> port-forward svc/<release>-elasticsearch 9200:9200
curl http://127.0.0.1:9200/_cluster/health
```

## Configuration

### Metrics

Elasticsearch has no built in Prometheus endpoint. Setting `metrics.enabled=true`
runs a community `elasticsearch_exporter` sidecar that scrapes the local node and
exposes metrics on port 9114 at `/metrics`. The exporter port is added to the
Service, and the ServiceMonitor switches to it when both flags are on.

```sh
helm install my-elasticsearch kymelio/elasticsearch \
  --set metrics.enabled=true \
  --set metrics.serviceMonitor.enabled=true
```

### Native configuration

Use `elasticsearchConfig` to provide an `elasticsearch.yml`, mounted over the
image default. This is the native tuning mechanism alongside `extraEnv` and the
generic `configuration` surface.

```yaml
elasticsearchConfig: |
  thread_pool.write.queue_size: 1000
  indices.memory.index_buffer_size: 20%
```

### TLS

Elasticsearch HTTP TLS is configured through `xpack.security.http.ssl.*` in
`elasticsearch.yml`. Set `tls.enabled=true` to mount a certificate Secret, then
reference the mounted files from `elasticsearchConfig`.

```yaml
tls:
  enabled: true
  existingSecret: elasticsearch-http-tls
elasticsearchConfig: |
  xpack.security.http.ssl.enabled: true
  xpack.security.http.ssl.certificate: /usr/share/elasticsearch/config/certs/tls.crt
  xpack.security.http.ssl.key: /usr/share/elasticsearch/config/certs/tls.key
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `docker.elastic.co/elasticsearch/elasticsearch` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.http.port | int | `9200` | HTTP API port |
| service.http.portName | string | `http` | HTTP API port name |
| service.transport.port | int | `9300` | Node transport port |
| service.transport.portName | string | `transport` | Node transport port name |
| esJavaOpts | string | `-Xms512m -Xmx512m` | JVM heap and options passed via ES_JAVA_OPTS |
| extraEnv | list | `[]` | Extra environment variables appended to the container |
| persistence.enabled | bool | `true` | Enable a PersistentVolumeClaim |
| persistence.storageClass | string | `""` | StorageClass, empty uses the cluster default |
| persistence.size | string | `8Gi` | Size of the data volume |
| persistence.mountPath | string | `/usr/share/elasticsearch/data` | Data mount path |
| ingress.enabled | bool | `false` | Enable an Ingress resource targeting the HTTP port |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| podDisruptionBudget.enabled | bool | `false` | Enable a PodDisruptionBudget |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Run an elasticsearch_exporter sidecar exposing metrics |
| metrics.image.repository | string | `quay.io/prometheuscommunity/elasticsearch-exporter` | Exporter image repository |
| metrics.image.tag | string | `v1.7.0` | Exporter image tag |
| metrics.port | int | `9114` | Exporter listen and Service port |
| metrics.esUri | string | `http://127.0.0.1:9200` | URI the exporter scrapes |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| elasticsearchConfig | string | `""` | Native elasticsearch.yml contents, mounted over the default |
| tls.enabled | bool | `false` | Mount a certificate Secret for HTTP TLS |
| tls.existingSecret | string | `""` | Secret holding the certificate and key |
| tls.certFilename | string | `tls.crt` | Certificate file name in the Secret |
| tls.keyFilename | string | `tls.key` | Private key file name in the Secret |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |
