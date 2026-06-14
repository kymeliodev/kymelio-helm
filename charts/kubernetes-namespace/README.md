# kubernetes-namespace

Provision a Kubernetes namespace with quota, limits and isolation.

This chart does not deploy any workload. It creates a Namespace and a set of
governance objects scoped to it: a ResourceQuota, a LimitRange and a default
deny NetworkPolicy. Use it to stamp out consistently governed namespaces for
teams or environments.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install team-a kymelio/kubernetes-namespace --set namespace.name=team-a
```

### OCI registry

```sh
helm install team-a oci://ghcr.io/kymeliodev/kymelio-helm/kubernetes-namespace \
  --version 0.1.0 --set namespace.name=team-a
```

## Uninstall

```sh
helm uninstall team-a
```

Uninstalling removes the Namespace and everything inside it. Make sure the
namespace holds nothing you need to keep before uninstalling.

## What it creates

| Object | Toggle | Description |
|--------|--------|-------------|
| Namespace | always | The namespace named by `namespace.name` |
| ResourceQuota | `resourceQuota.enabled` | Caps aggregate CPU, memory and pod count |
| LimitRange | `limitRange.enabled` | Applies default container requests and limits |
| NetworkPolicy | `networkPolicy.enabled` | Default deny for ingress and egress |

The default deny NetworkPolicy blocks all pod traffic in the namespace until you
add explicit allow policies next to it.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| namespace.name | string | `example` | Name of the Namespace to create, required |
| namespace.labels | object | `{}` | Extra labels applied to the Namespace |
| namespace.annotations | object | `{}` | Extra annotations applied to the Namespace |
| resourceQuota.enabled | bool | `true` | Create a ResourceQuota in the namespace |
| resourceQuota.hard | object | cpu, memory, pods | Hard limits enforced by the quota |
| limitRange.enabled | bool | `true` | Create a LimitRange in the namespace |
| limitRange.limits | list | container defaults | Default and request limits per type |
| networkPolicy.enabled | bool | `true` | Create a default deny NetworkPolicy |
