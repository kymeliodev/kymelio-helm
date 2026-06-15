# scylladb

A Helm chart for ScyllaDB, a Cassandra-compatible NoSQL database. This chart
deploys a single node as a StatefulSet with persistent storage. The node runs
with `--smp 1 --overprovisioned 1` so it can operate in resource constrained
environments.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-scylladb kymelio/scylladb
```

### OCI registry

```sh
helm install my-scylladb oci://ghcr.io/kymeliodev/kymelio-helm/scylladb --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-scylladb
```

Uninstalling does not remove the PersistentVolumeClaim created by the
StatefulSet. Delete the PVC manually if you no longer need the data:

```sh
kubectl delete pvc -l app.kubernetes.io/instance=my-scylladb
```

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-scylladb kymelio/scylladb --reuse-values
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `docker.io/scylladb/scylla` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `9042` | CQL service port |
| persistence.enabled | bool | `true` | Enable a PersistentVolumeClaim for data |
| persistence.storageClass | string | `""` | StorageClass, empty uses the cluster default |
| persistence.size | string | `8Gi` | Size of the persistent volume |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot, uid 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
