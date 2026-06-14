# mimir

Mimir horizontally scalable, long term storage for Prometheus metrics. This chart runs Mimir in monolithic mode as a StatefulSet with `-target=all` and a filesystem storage backend. The configuration is rendered from a ConfigMap and mounted at `/etc/mimir/mimir.yaml`, with data kept on a persistent volume.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-mimir kymelio/mimir
```

### OCI registry

```sh
helm install my-mimir oci://ghcr.io/kymeliodev/kymelio-helm/mimir --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-mimir
```

## Configuration

The Mimir configuration is provided through `config` as a YAML string and mounted at `/etc/mimir/mimir.yaml`. The default is a monolithic, filesystem backed setup with a replication factor of one, suitable for a single replica. A change to `config` updates a checksum annotation on the pod so it is rolled automatically.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `docker.io/grafana/mimir` | Container image repository |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| args | list | config.file and target all | Command line arguments passed to Mimir |
| config | string | monolithic filesystem | Mimir configuration mounted as mimir.yaml |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `8080` | HTTP service port |
| persistence.enabled | bool | `true` | Enable a persistent volume for /data |
| persistence.size | string | `8Gi` | Persistent volume size |
| persistence.mountPath | string | `/data` | Data directory mount path |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsUser 10001 | Pod security context |
| securityContext | object | drop ALL | Container security context |
