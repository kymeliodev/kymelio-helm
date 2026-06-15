# codey

A Helm chart for Codey, a self hosted Git service and code hosting platform.

## Base image

Codey does not publish a dedicated, well known container image. This chart uses
the official Gitea image (`docker.io/gitea/gitea`) as the runtime base, which
provides a compatible, lightweight Git service. Override `image.repository` and
`image.tag` if you maintain your own Codey build.

## Storage and database

Codey stores repositories, configuration and the embedded SQLite database under
`/data`. The default `extraEnv` sets `GITEA__database__DB_TYPE=sqlite3`.
Override the `GITEA__database__*` variables to use an external PostgreSQL or
MySQL server.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-codey kymelio/codey
```

### OCI registry

```sh
helm install my-codey oci://ghcr.io/kymeliodev/kymelio-helm/codey --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-codey
```

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-codey kymelio/codey --reuse-values
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `docker.io/gitea/gitea` | Container image repository (Gitea base) |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `3000` | HTTP service port |
| service.portName | string | `http` | HTTP port name |
| persistence.enabled | bool | `true` | Enable persistent storage for /data |
| persistence.size | string | `8Gi` | Persistent volume size |
| persistence.mountPath | string | `/data` | Mount path for Codey data |
| extraEnv | list | sqlite3 | Extra environment variables |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot, uid 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |
| metrics.enabled | bool | `false` | Enable the built in Prometheus endpoint on the HTTP port |
| metrics.token | string | `""` | Bearer token required to scrape /metrics |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| metrics.serviceMonitor.path | string | `/metrics` | Path scraped by Prometheus |

## Configuration

### Metrics

The Gitea base image exposes a built in Prometheus endpoint at `/metrics` on the
HTTP port (`3000`). Set `metrics.enabled=true` to inject
`GITEA__metrics__ENABLED=true` and let the server expose the endpoint. Enable the
ServiceMonitor to have Prometheus scrape it:

```sh
helm install my-codey kymelio/codey \
  --set metrics.enabled=true \
  --set metrics.serviceMonitor.enabled=true
```

Restrict the endpoint to authorized scrapers by setting a token, which renders
`GITEA__metrics__TOKEN`:

```sh
helm install my-codey kymelio/codey \
  --set metrics.enabled=true \
  --set metrics.token=changeme
```

### Native configuration

The runtime reads its configuration from `GITEA__<section>__<KEY>` environment
variables. Tune any section through `extraEnv`, for example to use an external
PostgreSQL server:

```yaml
extraEnv:
  - name: GITEA__database__DB_TYPE
    value: postgres
  - name: GITEA__database__HOST
    value: postgres.db.svc:5432
  - name: GITEA__database__NAME
    value: codey
  - name: GITEA__server__ROOT_URL
    value: https://code.example.com/
```

The generic `configuration` surface remains available to mount an inline
`app.ini` through a ConfigMap when you prefer a file over environment variables.

### TLS

The service is normally fronted by an Ingress or a reverse proxy that terminates
TLS, so the chart does not serve TLS from the container. Enable `ingress` and
attach a certificate Secret there:

```yaml
ingress:
  enabled: true
  className: nginx
  hosts:
    - host: code.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: codey-tls
      hosts:
        - code.example.com
```
