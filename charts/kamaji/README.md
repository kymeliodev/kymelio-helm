# kamaji

Deploys the Kamaji operator as a Kubernetes Deployment. Kamaji runs Kubernetes
control planes as pods on a management cluster, letting many tenant clusters
share the same infrastructure. The operator reconciles TenantControlPlane
custom resources and the workloads that back each hosted control plane.

The operator exposes two ports: the primary `metrics` port (8080) and a
secondary `webhook` port (9443) serving the admission webhook.

The Kamaji custom resource definitions (TenantControlPlane, DataStore and
related CRDs) are not authored by this chart and must be installed separately
before the operator can reconcile any resources.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-kamaji kymelio/kamaji
```

### OCI registry

```sh
helm install my-kamaji oci://ghcr.io/kymeliodev/kymelio-helm/kamaji --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-kamaji
```

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-kamaji kymelio/kamaji --reuse-values
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of operator replicas when autoscaling is disabled |
| image.repository | string | `docker.io/clastix/kamaji` | Operator image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| serviceAccount.create | bool | `true` | Create a service account for the operator |
| rbac.create | bool | `true` | Create the ClusterRole and ClusterRoleBinding for the operator |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `8080` | Primary metrics port |
| service.portName | string | `metrics` | Name of the metrics port |
| service.webhookPort | int | `9443` | Secondary admission webhook port |
| service.webhookPortName | string | `webhook` | Name of the webhook port |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| podDisruptionBudget.enabled | bool | `false` | Enable a PodDisruptionBudget |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot, uid 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |
