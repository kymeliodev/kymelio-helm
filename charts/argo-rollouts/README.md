# argo-rollouts

Deploys the Argo Rollouts controller as a Kubernetes Deployment. The controller
provides progressive delivery strategies such as canary and blue-green by
reconciling Rollout custom resources and the workloads they drive.

The controller exposes two ports: the primary `metrics` port (8090) and a
secondary `http` health port (8080).

The Argo Rollouts custom resource definitions (Rollout, AnalysisTemplate,
Experiment and related CRDs) are not authored by this chart and must be
installed separately before the controller can reconcile any resources.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-argo-rollouts kymelio/argo-rollouts
```

### OCI registry

```sh
helm install my-argo-rollouts oci://ghcr.io/kymeliodev/kymelio-helm/argo-rollouts --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-argo-rollouts
```

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-argo-rollouts kymelio/argo-rollouts --reuse-values
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of controller replicas when autoscaling is disabled |
| image.repository | string | `quay.io/argoproj/argo-rollouts` | Controller image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| serviceAccount.create | bool | `true` | Create a service account for the controller |
| rbac.create | bool | `true` | Create the ClusterRole and ClusterRoleBinding for the controller |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `8090` | Primary metrics port |
| service.portName | string | `metrics` | Name of the metrics port |
| service.healthPort | int | `8080` | Secondary health port |
| service.healthPortName | string | `http` | Name of the health port |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| podDisruptionBudget.enabled | bool | `false` | Enable a PodDisruptionBudget |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot, uid 999 | Pod security context |
| securityContext | object | drop ALL | Container security context |
