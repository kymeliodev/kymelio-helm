# opencloud

Helm chart for [OpenCloud](https://opencloud.eu/), a self hosted file platform
for storage, sharing and collaboration.

The chart deploys OpenCloud as a StatefulSet with a persistent volume mounted at
`/var/lib/opencloud`. The initial administrator password is sourced from a
Secret.

## Image

OpenCloud does not publish a single canonical container image name across all
channels. This chart defaults to the rolling image
`docker.io/opencloudeu/opencloud-rolling`, which tracks the current release line.
Pin `image.tag` to a fixed release tag for reproducible deployments and override
`image.repository` if you mirror the image into a private registry.

## Configuration

OpenCloud is served behind a reverse proxy or ingress that terminates TLS. The
proxy inside the pod listens on `0.0.0.0:9200` via `PROXY_HTTP_ADDR`, and
`OC_INSECURE` is set to `true` so internal service to service calls do not fail
TLS verification. Set `insecure: false` and provide proper certificates when
running a fully internal TLS chain. Point `ingress.hosts[0].host` at the public
host name, which is passed to the container as `OC_URL`.

### Application settings

OpenCloud services are configured through environment variables. Add any
documented `OC_*` or service specific variable through `extraEnv`:

```yaml
extraEnv:
  - name: OC_LOG_LEVEL
    value: info
  - name: PROXY_TLS
    value: "false"
```

### TLS

OpenCloud is normally fronted by an ingress or reverse proxy that terminates
TLS, which is why `OC_INSECURE` is `true` and the in pod proxy serves plain HTTP
on `PROXY_HTTP_ADDR`. The proxy service can also terminate TLS itself; set
`insecure: false`, configure `PROXY_TLS` and mount certificates through
`extraVolumes`/`extraVolumeMounts` if you run a fully internal TLS chain.

### Metrics

OpenCloud (oCIS) exposes Prometheus metrics on a debug endpoint. By default that
endpoint binds to `127.0.0.1:9205` and is not reachable from outside the pod.
When `metrics.enabled` is set, the chart binds the proxy debug endpoint to all
interfaces via `PROXY_DEBUG_ADDR=0.0.0.0:9205`, publishes it as the named
`metrics` port and, when the ServiceMonitor is enabled, scrapes it at
`metrics.path` (requires the Prometheus Operator CRDs):

```yaml
metrics:
  enabled: true
  port: 9205
  path: /metrics
  serviceMonitor:
    enabled: true
    interval: 30s
    labels:
      release: kube-prometheus-stack
```

The single binary deployment fronts the suite with the proxy service, so the
proxy debug endpoint is the one exposed here. Consider restricting access to the
metrics port with a NetworkPolicy, since the debug endpoint is unauthenticated
unless an `OCIS_DEBUG_TOKEN` is configured.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-opencloud kymelio/opencloud
```

### OCI registry

```sh
helm install my-opencloud oci://ghcr.io/kymeliodev/kymelio-helm/opencloud --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-opencloud
```

## Upgrading

```sh
helm upgrade my-opencloud kymelio/opencloud --reuse-values
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `docker.io/opencloudeu/opencloud-rolling` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| auth.adminUser | string | `admin` | Administrator user name |
| auth.adminPassword | string | `""` | Administrator password, generated when empty (IDM_ADMIN_PASSWORD) |
| auth.existingSecret | string | `""` | Existing Secret holding the admin password |
| auth.secretKeys.passwordKey | string | `admin-password` | Key in the Secret holding the admin password |
| insecure | bool | `true` | Set OC_INSECURE to skip internal TLS verification |
| persistence.enabled | bool | `true` | Provision a PersistentVolumeClaim |
| persistence.size | string | `8Gi` | Volume size |
| persistence.mountPath | string | `/var/lib/opencloud` | Data mount path |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `9200` | Service port, named http |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| podDisruptionBudget.enabled | bool | `false` | Enable a PodDisruptionBudget |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Bind the proxy debug endpoint to 0.0.0.0 and publish the metrics port |
| metrics.port | int | `9205` | Container and service port for the debug/metrics endpoint |
| metrics.path | string | `/metrics` | HTTP path of the Prometheus metrics endpoint |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor scraping the metrics port |
| extraEnv | list | `[]` | Extra environment variables passed to the container |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsUser 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |
