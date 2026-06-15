# zot

A Helm chart for zot, an OCI native container image registry from Project Zot.
zot stores and distributes container images and OCI artifacts with a minimal
footprint.

## Configuration

The chart renders `.Values.config` as `config.json` into a ConfigMap and mounts
it at `/etc/zot/config.json`. The container starts with
`serve /etc/zot/config.json`. The defaults bind the HTTP server to
`0.0.0.0:5000` and set the storage `rootDirectory` to `/var/lib/registry`,
which is the persistent volume mount path. Extend `config` to enable
authentication, TLS, sync or other zot features.

## Storage

Registry blobs and metadata are persisted under `/var/lib/registry` through the
StatefulSet volume claim template.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-zot kymelio/zot
```

### OCI registry

```sh
helm install my-zot oci://ghcr.io/kymeliodev/kymelio-helm/zot --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-zot
```

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-zot kymelio/zot --reuse-values
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `ghcr.io/project-zot/zot` | Container image repository |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `5000` | HTTP service port |
| service.portName | string | `http` | HTTP port name |
| config.http.address | string | `0.0.0.0` | HTTP bind address |
| config.http.port | int | `5000` | HTTP listen port |
| config.storage.rootDirectory | string | `/var/lib/registry` | Storage root directory |
| persistence.enabled | bool | `true` | Enable persistent storage |
| persistence.size | string | `8Gi` | Persistent volume size |
| persistence.mountPath | string | `/var/lib/registry` | Mount path for registry data |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot, uid 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |
| metrics.enabled | bool | `false` | Enable the native zot metrics extension on the HTTP port |
| metrics.path | string | `/metrics` | Path where zot serves Prometheus metrics |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| tls.enabled | bool | `false` | Serve TLS from zot using an http.tls block |
| tls.existingSecret | string | `""` | Secret holding the certificate and key |
| tls.certFilename | string | `tls.crt` | Certificate file name inside the Secret |
| tls.keyFilename | string | `tls.key` | Private key file name inside the Secret |

### Metrics

zot ships a native metrics extension. Set `metrics.enabled=true` to add
`extensions.metrics` to the rendered `config.json`, which makes zot serve
Prometheus metrics at `/metrics` on the HTTP port (`5000`). Enable the
ServiceMonitor so Prometheus scrapes it:

```sh
helm install my-zot kymelio/zot \
  --set metrics.enabled=true \
  --set metrics.serviceMonitor.enabled=true
```

The rendered extension looks like:

```json
"extensions": { "metrics": { "enable": true, "prometheus": { "path": "/metrics" } } }
```

### Native tuning

Add any zot setting under `config`; it is merged into `config.json`. For example
to require authentication with an htpasswd file and raise the log level:

```yaml
config:
  http:
    address: 0.0.0.0
    port: 5000
    auth:
      htpasswd:
        path: /etc/zot/htpasswd
  log:
    level: debug
```

### TLS

zot terminates TLS itself. Set `tls.enabled=true` and point `tls.existingSecret`
at a Secret containing `tls.crt` and `tls.key`. The chart mounts the Secret at
`/etc/zot/tls` and adds an `http.tls` block to `config.json`, and the probes
switch to HTTPS:

```sh
helm install my-zot kymelio/zot \
  --set tls.enabled=true \
  --set tls.existingSecret=zot-tls
```
