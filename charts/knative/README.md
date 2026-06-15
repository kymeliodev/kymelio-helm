# knative

Deploys the Knative Serving controller as a Kubernetes Deployment. This is the
Knative Serving controller component: it reconciles Knative Serving resources
such as Services, Configurations, Revisions and Routes to run serverless,
scale-to-zero workloads on Kubernetes.

This chart deploys only the Serving controller. The Knative Serving custom
resource definitions and the other Serving components (activator, autoscaler,
webhook and a networking layer such as Kourier or Istio) are not authored by
this chart and must be installed separately for a working Knative Serving
installation.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-knative kymelio/knative
```

### OCI registry

```sh
helm install my-knative oci://ghcr.io/kymeliodev/kymelio-helm/knative --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-knative
```

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-knative kymelio/knative --reuse-values
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of controller replicas when autoscaling is disabled |
| image.repository | string | `gcr.io/knative-releases/knative.dev/serving/cmd/controller` | Controller image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| serviceAccount.create | bool | `true` | Create a service account for the controller |
| rbac.create | bool | `true` | Create the ClusterRole and ClusterRoleBinding for the controller |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `9090` | Metrics port exposed by the controller |
| service.portName | string | `metrics` | Name of the metrics port |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| podDisruptionBudget.enabled | bool | `false` | Enable a PodDisruptionBudget |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Enable Prometheus integration for the controller metrics endpoint |
| metrics.path | string | `/metrics` | HTTP path where the controller exposes metrics |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor (requires metrics.enabled) |
| metrics.serviceMonitor.interval | string | `30s` | Scrape interval for the ServiceMonitor |
| metrics.serviceMonitor.scrapeTimeout | string | `10s` | Scrape timeout for the ServiceMonitor |
| metrics.serviceMonitor.labels | object | `{}` | Extra labels added to the ServiceMonitor |
| extraArgs | list | `[]` | Extra arguments appended to the controller entrypoint |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot, uid 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |

## Configuration

### Prometheus metrics

The serving controller serves Prometheus metrics on the service port (`9090`)
at `/metrics`. The port is exposed by the controller natively. Set
`metrics.enabled` to turn on the Prometheus integration and create a
`ServiceMonitor` for the Prometheus Operator:

```yaml
metrics:
  enabled: true
  serviceMonitor:
    enabled: true
    interval: 30s
    scrapeTimeout: 10s
    labels:
      release: kube-prometheus-stack
```

If you do not run the Prometheus Operator, leave `serviceMonitor.enabled` at
`false` and scrape the Service directly:

```
release-name-knative.<namespace>.svc.cluster.local:9090/metrics
```

### Controller tuning

Pass additional controller flags through `extraArgs`, for example to raise the
log level:

```yaml
extraArgs:
  - --zap-log-level=debug
```
