# cluster-api-operator

Deploys the Cluster API Operator as a Kubernetes Deployment. The operator
manages the lifecycle of Cluster API providers (core, bootstrap, control plane
and infrastructure providers) by reconciling their operator custom resources
and installing the matching provider components.

The Cluster API custom resource definitions, including the operator provider
CRDs and the CRDs shipped by each provider, are not authored by this chart and
must be installed separately before the operator can reconcile any resources.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-cluster-api-operator kymelio/cluster-api-operator
```

### OCI registry

```sh
helm install my-cluster-api-operator oci://ghcr.io/kymeliodev/kymelio-helm/cluster-api-operator --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-cluster-api-operator
```

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-cluster-api-operator kymelio/cluster-api-operator --reuse-values
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of operator replicas when autoscaling is disabled |
| image.repository | string | `registry.k8s.io/capi-operator/cluster-api-operator` | Operator image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| serviceAccount.create | bool | `true` | Create a service account for the operator |
| rbac.create | bool | `true` | Create the ClusterRole and ClusterRoleBinding for the operator |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `8080` | Metrics port exposed by the operator |
| service.portName | string | `metrics` | Name of the metrics port |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| podDisruptionBudget.enabled | bool | `false` | Enable a PodDisruptionBudget |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot, uid 65532 | Pod security context |
| securityContext | object | drop ALL | Container security context |
