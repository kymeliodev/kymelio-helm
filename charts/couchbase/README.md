# couchbase

Couchbase Server, deployed as a single node StatefulSet with persistent
storage. This chart does not run an automated cluster init. The administrator
credentials are stored in a Secret for reference, and the cluster must be
initialized manually through the web console.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-couchbase kymelio/couchbase
```

### OCI registry

```sh
helm install my-couchbase oci://ghcr.io/kymeliodev/kymelio-helm/couchbase --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-couchbase
```

The PersistentVolumeClaim is retained after uninstall. Delete it manually to
discard the data.

## Upgrading

Review the chart version change and your overridden values before upgrading. A
generated password is preserved across upgrades when you keep `auth.password`
empty and reuse the release Secret.

```sh
helm upgrade my-couchbase kymelio/couchbase
```

## Configuration

### Metrics

Couchbase Server exposes a native Prometheus endpoint on the admin port (8091) at
`/metrics`. The endpoint requires authentication, so enabling metrics wires the
ServiceMonitor with `basicAuth` that references the administrator Secret. Metrics
share the admin port, so no extra container port is opened.

```yaml
metrics:
  enabled: true
  serviceMonitor:
    enabled: true
```

### Config tuning

Couchbase is configured at runtime through its management API. For chart level
tuning, pass extra environment variables through `extraEnv`, extra arguments through
`extraArgs`, or mount a native config file through the generic `configuration`
value:

```yaml
extraEnv:
  - name: CB_REST_USERNAME
    value: Administrator
configuration: |
  # mounted at configMountPath for use by init scripts or tooling
```

### TLS

Couchbase serves the management UI and data services over TLS on dedicated secure
ports (18091 and 11207). Provide a Secret holding the certificate chain and key and
enable `tls`; the Secret is mounted read only at `tls.mountPath` for the node to
load, and the secure ports are added to the Service.

```sh
helm install my-couchbase kymelio/couchbase \
  --set tls.enabled=true \
  --set tls.existingSecret=couchbase-tls
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas, fixed at one |
| image.repository | string | `docker.io/couchbase/server` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| auth.username | string | `Administrator` | Administrator user name, for reference only |
| auth.password | string | `""` | Administrator password, generated when empty |
| auth.existingSecret | string | `""` | Use an existing Secret for credentials |
| auth.secretKeys.passwordKey | string | `couchbase-admin-password` | Secret key holding the password |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.ports.admin.port | int | `8091` | Admin console port |
| service.ports.data.port | int | `11210` | Data port |
| persistence.enabled | bool | `true` | Enable a PersistentVolumeClaim |
| persistence.storageClass | string | `""` | StorageClass, empty uses the cluster default |
| persistence.size | string | `8Gi` | Size of the data volume |
| persistence.mountPath | string | `/opt/couchbase/var` | Mount path for the data volume |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Scrape the native Prometheus endpoint on the admin port |
| metrics.path | string | `/metrics` | Metrics path on the admin port |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor with basicAuth |
| tls.enabled | bool | `false` | Mount a TLS certificate and expose the secure ports |
| tls.existingSecret | string | `""` | Secret holding the certificate chain and key |
