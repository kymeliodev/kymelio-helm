# tekton

Tekton Pipelines controller for cloud native CI/CD, deployed as a stateless
Deployment running the pipelines controller.

This chart installs only the pipelines controller. A complete Tekton Pipelines
installation also requires the following, which are installed separately:

- The Tekton Pipelines Custom Resource Definitions. This chart does not ship
  CRDs.
- The webhook admission component and its configuration.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-tekton kymelio/tekton
```

### OCI registry

```sh
helm install my-tekton oci://ghcr.io/kymeliodev/kymelio-helm/tekton --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-tekton
```

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-tekton kymelio/tekton --reuse-values
```

## Configuration

### Metrics

The pipelines controller publishes Prometheus metrics on a dedicated port at
`/metrics`. The endpoint is built in and needs no extra flag. Set
`metrics.enabled=true` to publish a `metrics` port (default `9090`) on the
Deployment and Service, and `metrics.serviceMonitor.enabled=true` to create a
ServiceMonitor for the Prometheus Operator that scrapes that port at
`metrics.path`.

```yaml
metrics:
  enabled: true
  port: 9090
  path: /metrics
  serviceMonitor:
    enabled: true
    interval: 30s
    scrapeTimeout: 10s
    labels:
      release: kube-prometheus-stack
```

### Controller flags

Controller behaviour is tuned with command line flags through `extraArgs`, for
example to raise the namespace scope or threads per controller:

```yaml
extraArgs:
  - --threads-per-controller=4
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `ghcr.io/tektoncd/pipeline/controller` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `8080` | Service port |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| podDisruptionBudget.enabled | bool | `false` | Enable a PodDisruptionBudget |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Publish a dedicated metrics port on the Deployment and Service |
| metrics.port | int | `9090` | Container and Service port for the metrics endpoint |
| metrics.path | string | `/metrics` | Path the metrics endpoint is served on |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| extraArgs | list | `[]` | Extra command line flags appended to the controller |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot | Pod security context |
| securityContext | object | drop ALL | Container security context |
