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
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsUser 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |
