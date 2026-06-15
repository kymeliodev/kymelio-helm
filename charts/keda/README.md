# keda

Deploys the KEDA operator as a Kubernetes Deployment. KEDA (Kubernetes
Event-Driven Autoscaling) scales workloads based on event sources by
reconciling ScaledObject and ScaledJob custom resources and managing the
HorizontalPodAutoscalers they create.

The operator exposes two ports: the primary `metrics` port (8080) and a
secondary `health` port (8081). It runs with leader election enabled.

The KEDA custom resource definitions (ScaledObject, ScaledJob,
TriggerAuthentication and related CRDs) are not authored by this chart and must
be installed separately before the operator can reconcile any resources.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-keda kymelio/keda
```

### OCI registry

```sh
helm install my-keda oci://ghcr.io/kymeliodev/kymelio-helm/keda --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-keda
```

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-keda kymelio/keda --reuse-values
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of operator replicas when autoscaling is disabled |
| image.repository | string | `ghcr.io/kedacore/keda` | Operator image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| serviceAccount.create | bool | `true` | Create a service account for the operator |
| rbac.create | bool | `true` | Create the ClusterRole and ClusterRoleBinding for the operator |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `8080` | Primary metrics port |
| service.portName | string | `metrics` | Name of the metrics port |
| service.healthPort | int | `8081` | Secondary health port |
| service.healthPortName | string | `health` | Name of the health port |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| podDisruptionBudget.enabled | bool | `false` | Enable a PodDisruptionBudget |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Enable Prometheus integration for the operator metrics endpoint |
| metrics.path | string | `/metrics` | HTTP path where the operator exposes metrics |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor (requires metrics.enabled) |
| metrics.serviceMonitor.interval | string | `30s` | Scrape interval for the ServiceMonitor |
| metrics.serviceMonitor.scrapeTimeout | string | `10s` | Scrape timeout for the ServiceMonitor |
| metrics.serviceMonitor.labels | object | `{}` | Extra labels added to the ServiceMonitor |
| extraArgs | list | `[]` | Extra arguments appended to the operator entrypoint |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot, uid 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |

## Configuration

### Prometheus metrics

The KEDA operator serves Prometheus metrics on the service port (`8080`) at
`/metrics`. The port is exposed by the operator natively. Set `metrics.enabled`
to turn on the Prometheus integration and create a `ServiceMonitor` for the
Prometheus Operator:

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
release-name-keda.<namespace>.svc.cluster.local:8080/metrics
```

### Operator tuning

The operator binds its metrics endpoint with `--metrics-bind-address`. Pass it
and other flags through `extraArgs`. For example, to change the metrics bind
address (keep it aligned with `service.port`) and raise the log level:

```yaml
extraArgs:
  - --metrics-bind-address=:8080
  - --zap-log-level=debug
```
