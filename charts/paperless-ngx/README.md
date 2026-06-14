# paperless-ngx

A Helm chart for paperless-ngx.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-paperless-ngx kymelio/paperless-ngx
```

### OCI registry

```sh
helm install my-paperless-ngx oci://ghcr.io/kymeliodev/kymelio-helm/paperless-ngx --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-paperless-ngx
```

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-paperless-ngx kymelio/paperless-ngx --reuse-values
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `""` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `8080` | Service port |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| podDisruptionBudget.enabled | bool | `false` | Enable a PodDisruptionBudget |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot | Pod security context |
| securityContext | object | drop ALL | Container security context |
