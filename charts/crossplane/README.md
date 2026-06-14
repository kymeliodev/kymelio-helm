# crossplane

Crossplane control plane core for cloud infrastructure composition, deployed as
a stateless Deployment running `crossplane core start`.

Crossplane turns a Kubernetes cluster into a control plane for provisioning and
managing external infrastructure through declarative APIs. This chart installs
the core control plane only. The Crossplane Custom Resource Definitions, along
with Providers and Configurations, are installed separately. This chart does not
ship CRDs.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-crossplane kymelio/crossplane
```

### OCI registry

```sh
helm install my-crossplane oci://ghcr.io/kymeliodev/kymelio-helm/crossplane --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-crossplane
```

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-crossplane kymelio/crossplane --reuse-values
```

## RBAC

The chart creates a ServiceAccount and a ClusterRole with a ClusterRoleBinding
so the control plane can reconcile Crossplane resources and manage the CRDs and
RBAC required by installed Providers. Set `rbac.create=false` to manage these
bindings yourself.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `docker.io/crossplane/crossplane` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| command | list | `["crossplane"]` | Container entrypoint command |
| args | list | `["core", "start"]` | Arguments passed to the control plane |
| serviceAccount.create | bool | `true` | Create a ServiceAccount for the control plane |
| rbac.create | bool | `true` | Create the ClusterRole and ClusterRoleBinding |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `8080` | Metrics service port |
| service.portName | string | `metrics` | Metrics port name |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| podDisruptionBudget.enabled | bool | `false` | Enable a PodDisruptionBudget |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |
