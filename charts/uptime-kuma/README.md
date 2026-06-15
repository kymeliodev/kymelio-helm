# uptime-kuma

Self hosted monitoring tool, deployed as a single StatefulSet with persistent
storage. It runs scheduled checks against your endpoints, raises notifications
and publishes status pages from a web user interface. Monitors and history are
stored on the data volume mounted at `/app/data`.

The first time you open the user interface you create the administrator account.
No credentials are required at deploy time.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-uptime-kuma kymelio/uptime-kuma
```

### OCI registry

```sh
helm install my-uptime-kuma oci://ghcr.io/kymeliodev/kymelio-helm/uptime-kuma --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-uptime-kuma
```

The PersistentVolumeClaim is retained after uninstall. Delete it manually to
discard monitors and history.

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-uptime-kuma kymelio/uptime-kuma --reuse-values
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas, single node deployment |
| image.repository | string | `docker.io/louislam/uptime-kuma` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `3001` | HTTP service port |
| service.portName | string | `http` | Named service port |
| persistence.enabled | bool | `true` | Enable a PersistentVolumeClaim |
| persistence.storageClass | string | `""` | StorageClass, empty uses the cluster default |
| persistence.size | string | `8Gi` | Size of the data volume |
| persistence.mountPath | string | `/app/data` | Data directory mount path |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Publish a dedicated metrics Service port for the Prometheus endpoint |
| metrics.port | int | `3001` | Port published on the Service for the metrics endpoint |
| metrics.path | string | `/metrics` | HTTP path where Uptime Kuma exposes metrics |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor (requires metrics.enabled) |
| metrics.serviceMonitor.interval | string | `30s` | Scrape interval for the ServiceMonitor |
| metrics.serviceMonitor.scrapeTimeout | string | `10s` | Scrape timeout for the ServiceMonitor |
| metrics.serviceMonitor.labels | object | `{}` | Extra labels added to the ServiceMonitor |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |

## Configuration

### Prometheus metrics

Uptime Kuma exposes Prometheus metrics at `/metrics` on its http port (`3001`).
Set `metrics.enabled` to publish a dedicated `metrics` Service port and create a
`ServiceMonitor` for the Prometheus Operator:

```yaml
metrics:
  enabled: true
  serviceMonitor:
    enabled: true
    interval: 30s
    scrapeTimeout: 10s
    labels:
      release: kube-prometheus-stack
```

The `/metrics` endpoint is protected. By default it uses HTTP basic auth with
your Uptime Kuma username and password. Once you create the first API key in the
user interface, basic auth is disabled and the API key must be used instead
(passed as the basic auth password with an empty username). The ServiceMonitor
created by this chart does not carry credentials, so add a `basicAuth` block
that references a Secret holding the username and password (or the API key).
Create the Secret first:

```sh
kubectl create secret generic uptime-kuma-metrics \
  --from-literal=username=admin \
  --from-literal=password=<password-or-api-key>
```

Then attach it to the ServiceMonitor through `metrics.serviceMonitor.labels` and
a Prometheus Operator `basicAuth` reference, or patch the generated
ServiceMonitor to add:

```yaml
spec:
  endpoints:
    - port: metrics
      path: /metrics
      basicAuth:
        username:
          name: uptime-kuma-metrics
          key: username
        password:
          name: uptime-kuma-metrics
          key: password
```

If you do not run the Prometheus Operator, leave `serviceMonitor.enabled` at
`false` and scrape the Service directly with the same credentials:

```
release-name-uptime-kuma.<namespace>.svc.cluster.local:3001/metrics
```
