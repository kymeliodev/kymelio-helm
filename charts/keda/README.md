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
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot, uid 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |
