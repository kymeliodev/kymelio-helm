# argo-workflows

Deploys the Argo Workflows workflow controller as a Kubernetes Deployment. The
controller reconciles Workflow custom resources and orchestrates the pods that
make up each workflow.

The Argo Workflows custom resource definitions (Workflow, WorkflowTemplate,
CronWorkflow and related CRDs) are not authored by this chart and must be
installed separately before the controller can reconcile any resources.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-argo-workflows kymelio/argo-workflows
```

### OCI registry

```sh
helm install my-argo-workflows oci://ghcr.io/kymeliodev/kymelio-helm/argo-workflows --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-argo-workflows
```

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-argo-workflows kymelio/argo-workflows --reuse-values
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of controller replicas when autoscaling is disabled |
| image.repository | string | `quay.io/argoproj/workflow-controller` | Controller image repository |
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
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot, uid 8737 | Pod security context |
| securityContext | object | drop ALL | Container security context |
