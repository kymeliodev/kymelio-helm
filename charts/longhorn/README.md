# longhorn

Deploys the Longhorn manager, the control plane component of the Longhorn cloud
native distributed block storage system for Kubernetes.

This chart installs the manager as a Deployment together with its ServiceAccount
and cluster scoped RBAC. It does not install the Longhorn Custom Resource
Definitions, the per node engine and instance manager components, the CSI driver
or the UI. Those node level components are installed separately, typically from
the upstream Longhorn deployment manifests or the official Longhorn chart, and
must be present for the manager to operate.

## Host access exception

The Longhorn manager requires privileged host access to manage node disks,
mount points and the iSCSI stack. For this reason the pod runs as root (UID 0)
with `privileged: true` and `runAsNonRoot: false`. This is an intentional and
documented deviation from the hardened, non root baseline applied to the other
charts in this repository.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-longhorn kymelio/longhorn
```

### OCI registry

```sh
helm install my-longhorn oci://ghcr.io/kymeliodev/kymelio-helm/longhorn --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-longhorn
```

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-longhorn kymelio/longhorn --reuse-values
```

## Configuration

### Metrics

The longhorn-manager exposes Prometheus metrics at `/metrics` on the manager
port (9500). Enable metrics and the ServiceMonitor to scrape that endpoint.

```sh
helm install my-longhorn kymelio/longhorn \
  --set metrics.enabled=true \
  --set metrics.serviceMonitor.enabled=true
```

### Manager flags

Tune the manager with `parameters`, which are appended as `--key=value` flags.

```yaml
parameters:
  upgrade-version-check: "false"
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of manager replicas |
| image.repository | string | `docker.io/longhornio/longhorn-manager` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| command | list | `["longhorn-manager"]` | Container entrypoint |
| args | list | manager daemon args | Arguments passed to the manager |
| serviceAccount.create | bool | `true` | Create a ServiceAccount for the manager |
| rbac.create | bool | `true` | Create the ClusterRole and ClusterRoleBinding |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `9500` | Manager API port, named http |
| podSecurityContext | object | runAsUser 0 | Pod security context, host access exception |
| securityContext | object | privileged | Container security context, host access exception |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Scrape the manager /metrics endpoint via the ServiceMonitor |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| parameters | object | `{}` | Extra manager flags applied as --key=value |
