# vector

High performance observability data pipeline, deployed as a single Deployment.
The bundled pipeline reads from a demo_logs source and writes to a console sink,
while the GraphQL API is enabled on the api port for health checks and live
inspection. Replace `config` to point Vector at your own sources and sinks.

The Vector configuration is rendered from `config` into a ConfigMap and mounted
at `configMountPath` via subPath. A `checksum/config` annotation rolls the pods
when the configuration changes.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-vector kymelio/vector
```

### OCI registry

```sh
helm install my-vector oci://ghcr.io/kymeliodev/kymelio-helm/vector --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-vector
```

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-vector kymelio/vector --reuse-values
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `docker.io/timberio/vector` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| args | list | config flag | Command line flags for the Vector binary |
| config | object | demo_logs to console | Vector configuration rendered into a ConfigMap |
| configMountPath | string | `/etc/vector/vector.yaml` | Mount path of the configuration file |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `8686` | GraphQL API port |
| service.portName | string | `api` | Named service port |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |
