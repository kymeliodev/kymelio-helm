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

## Configuration

### Metrics

ScyllaDB serves Prometheus metrics natively on port 9180 at `/metrics`. Enabling
metrics passes `--prometheus-port` / `--prometheus-address` to the server, opens the
port on the container and Service, and lets the ServiceMonitor scrape it directly.

```yaml
metrics:
  enabled: true
  serviceMonitor:
    enabled: true
```

### Config tuning

Pass extra start flags through `extraArgs`, or set native `scylla.yaml` settings
through `scylla.configFragment`. The fragment is rendered into a ConfigMap and
mounted at `scylla.configFragmentMountPath`.

```yaml
scylla:
  configFragment: |
    authenticator: PasswordAuthenticator
    authorizer: CassandraAuthorizer
    compaction_static_shares: 100
extraArgs:
  - --memory
  - 2G
```

### TLS

Client encryption is configured through the `scylla.yaml` fragment. Provide a Secret
holding the certificate and key and enable `tls`:

```sh
helm install my-scylladb kymelio/scylladb \
  --set tls.enabled=true \
  --set tls.existingSecret=scylla-tls
```

The Secret is mounted read only at `tls.mountPath` and the chart writes the matching
`client_encryption_options` block into the rendered `scylla.yaml`.

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
| metrics.enabled | bool | `false` | Expose the native Prometheus endpoint on port 9180 |
| metrics.port | int | `9180` | Native Prometheus listener port |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| scylla.configFragment | string | `""` | Native scylla.yaml fragment mounted into the pod |
| tls.enabled | bool | `false` | Enable client TLS via scylla.yaml client_encryption_options |
| tls.existingSecret | string | `""` | Secret holding the certificate and key |
