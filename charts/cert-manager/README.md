# cert-manager

Controller that automates TLS certificate issuance and renewal, deployed as a
stateless Deployment.

This chart installs the cert-manager controller only. It creates a
ServiceAccount and the cluster scoped RBAC the controller needs to manage
certificates, issuers and the related ACME resources.

## Custom Resource Definitions

This chart does not install the cert-manager Custom Resource Definitions. The
CRDs for `Certificate`, `Issuer`, `ClusterIssuer`, `Order`, `Challenge` and the
other cert-manager types must be installed separately before the controller can
operate, for example by applying the release manifest published with the
matching cert-manager version. Install the CRDs first, then install this chart.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-cert-manager kymelio/cert-manager
```

### OCI registry

```sh
helm install my-cert-manager oci://ghcr.io/kymeliodev/kymelio-helm/cert-manager --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-cert-manager
```

## Upgrading

Review the chart version change and your overridden values before upgrading.
Confirm the installed CRDs match the controller version.

```sh
helm upgrade my-cert-manager kymelio/cert-manager
```

## RBAC

A ClusterRole and ClusterRoleBinding are created by default and bound to the
controller ServiceAccount. Set `rbac.create=false` to manage the cluster RBAC
out of band.

The controller is started with `--cluster-resource-namespace=$(POD_NAMESPACE)`
and `--leader-election-namespace=kube-system`. `POD_NAMESPACE` is provided from
the pod metadata through the downward API.

## Configuration

### Metrics

The cert-manager controller serves Prometheus metrics on container port `9402`
at `/metrics`. Set `metrics.enabled=true` to publish a dedicated `metrics` port
on the Service, and `metrics.serviceMonitor.enabled=true` to create a
ServiceMonitor for the Prometheus Operator.

```yaml
metrics:
  enabled: true
  port: 9402
  serviceMonitor:
    enabled: true
    interval: 30s
    scrapeTimeout: 10s
    labels:
      release: kube-prometheus-stack
```

### Controller flags

Controller behaviour is tuned with command line flags. The default flags are set
in `args`. Append additional flags with `extraArgs`, for example to raise the log
verbosity or set the DNS recursive nameservers:

```yaml
extraArgs:
  - --dns01-recursive-nameservers=1.1.1.1:53
  - --dns01-recursive-nameservers-only
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `quay.io/jetstack/cert-manager-controller` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| serviceAccount.create | bool | `true` | Create a ServiceAccount for the controller |
| rbac.create | bool | `true` | Create the cluster scoped RBAC |
| args | list | controller args | Arguments passed to the cert-manager controller |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `9402` | Metrics port |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| podDisruptionBudget.enabled | bool | `false` | Enable a PodDisruptionBudget |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Publish a dedicated metrics port on the Service |
| metrics.port | int | `9402` | Service port for the metrics endpoint |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| extraEnv | list | `[]` | Extra environment variables passed to the controller |
