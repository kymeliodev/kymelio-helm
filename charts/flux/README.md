# flux

Flux source-controller for GitOps artifact acquisition on Kubernetes, deployed
as a stateless Deployment.

The source-controller reconciles source resources such as GitRepository,
OCIRepository, HelmRepository and Bucket, then exposes the fetched artifacts
over an in cluster HTTP API for the other Flux controllers to consume.

This chart deploys only the source-controller. A complete Flux installation
also requires the following, which are installed separately:

- The other Flux controllers (kustomize-controller, helm-controller,
  notification-controller, image controllers).
- The Flux Custom Resource Definitions. This chart does not ship CRDs.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-flux kymelio/flux
```

### OCI registry

```sh
helm install my-flux oci://ghcr.io/kymeliodev/kymelio-helm/flux --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-flux
```

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-flux kymelio/flux --reuse-values
```

## RBAC

The chart creates a ServiceAccount and a ClusterRole with a ClusterRoleBinding
so the controller can reconcile source resources across all namespaces. Set
`rbac.create=false` to manage these bindings yourself.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `ghcr.io/fluxcd/source-controller` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| command | list | tini and source-controller | Container entrypoint command |
| args | list | watch-all-namespaces, storage-adv-addr | Arguments passed to the controller |
| serviceAccount.create | bool | `true` | Create a ServiceAccount for the controller |
| rbac.create | bool | `true` | Create the ClusterRole and ClusterRoleBinding |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.ports | list | http 9090, metrics 8080 | Service ports, the first entry is primary |
| ingress.enabled | bool | `false` | Enable an Ingress resource for the http port |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| podDisruptionBudget.enabled | bool | `false` | Enable a PodDisruptionBudget |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |
