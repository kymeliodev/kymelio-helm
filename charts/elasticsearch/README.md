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
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |
