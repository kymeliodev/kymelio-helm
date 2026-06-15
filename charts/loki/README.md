# loki

Loki horizontally scalable log aggregation system. This chart runs Loki in single binary mode as a StatefulSet using the filesystem for chunks and index. The configuration is rendered from a ConfigMap and mounted at `/etc/loki/loki.yaml`, with log data kept on a persistent volume.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-loki kymelio/loki
```

### OCI registry

```sh
helm install my-loki oci://ghcr.io/kymeliodev/kymelio-helm/loki --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-loki
```

## Configuration

The Loki configuration is provided through `config` as a YAML string and mounted at `/etc/loki/loki.yaml`. The default is a single binary, filesystem backed setup suitable for a single replica. A change to `config` updates a checksum annotation on the pod so it is rolled automatically.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `docker.io/grafana/loki` | Container image repository |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| args | list | config.file | Command line arguments passed to Loki |
| config | string | single binary filesystem | Loki configuration mounted as loki.yaml |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `3100` | HTTP service port |
| persistence.enabled | bool | `true` | Enable a persistent volume for /loki |
| persistence.size | string | `8Gi` | Persistent volume size |
| persistence.mountPath | string | `/loki` | Data directory mount path |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsUser 10001 | Pod security context |
| securityContext | object | drop ALL | Container security context |
