# rook-ceph

Deploys the Rook Ceph operator, which manages the lifecycle of Ceph storage
clusters running on Kubernetes.

This chart installs the operator as a Deployment together with its
ServiceAccount and cluster scoped RBAC. It does not install any storage
cluster. The CephCluster, CephBlockPool, CephFilesystem, CephObjectStore and the
other Rook Custom Resource Definitions are installed separately and must be
present before you create the corresponding custom resources.

After installing this chart, install the Rook CRDs and then create a
CephCluster resource (and any pool, filesystem or object store resources) to
provision storage. The operator watches those resources and reconciles the
Ceph daemons accordingly.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-rook-ceph kymelio/rook-ceph
```

### OCI registry

```sh
helm install my-rook-ceph oci://ghcr.io/kymeliodev/kymelio-helm/rook-ceph --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-rook-ceph
```

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-rook-ceph kymelio/rook-ceph --reuse-values
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of operator replicas |
| image.repository | string | `docker.io/rook/ceph` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| args | list | `["ceph","operator"]` | Arguments passed to the operator |
| serviceAccount.create | bool | `true` | Create a ServiceAccount for the operator |
| rbac.create | bool | `true` | Create the ClusterRole and ClusterRoleBinding |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `9443` | Webhook port, named webhook |
| podSecurityContext | object | runAsNonRoot 2016 | Pod security context |
| securityContext | object | drop ALL | Container security context |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
