# opa-gatekeeper

A Helm chart for opa-gatekeeper.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-opa-gatekeeper kymelio/opa-gatekeeper
```

### OCI registry

```sh
helm install my-opa-gatekeeper oci://ghcr.io/kymeliodev/kymelio-helm/opa-gatekeeper --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-opa-gatekeeper
```

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-opa-gatekeeper kymelio/opa-gatekeeper --reuse-values
```

## Configuration

### Metrics

The Gatekeeper controller manager serves Prometheus metrics on container port
`8888` at `/metrics`. Set `metrics.enabled=true` to publish a dedicated `metrics`
port on the Service, and `metrics.serviceMonitor.enabled=true` to create a
ServiceMonitor for the Prometheus Operator.

```yaml
metrics:
  enabled: true
  port: 8888
  serviceMonitor:
    enabled: true
    interval: 30s
    scrapeTimeout: 10s
    labels:
      release: kube-prometheus-stack
```

### Controller flags

The default `args` start the controller with `--operation=webhook` and
`--operation=status`. Append additional flags with `extraArgs`, for example to
raise the log level or emit admission events:

```yaml
extraArgs:
  - --log-level=DEBUG
  - --emit-admission-events
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `""` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `8888` | Service port |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| podDisruptionBudget.enabled | bool | `false` | Enable a PodDisruptionBudget |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Publish a dedicated metrics port on the Service |
| metrics.port | int | `8888` | Service port for the metrics endpoint |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot | Pod security context |
| securityContext | object | drop ALL | Container security context |
