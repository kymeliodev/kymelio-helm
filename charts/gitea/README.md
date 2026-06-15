# gitea

A Helm chart for Gitea, a self hosted lightweight Git service with issue
tracking, pull requests, a wiki and a built in package registry.

## Ports

The StatefulSet exposes two ports:

- `http` on `3000` for the web UI and HTTP Git access.
- `ssh` on `22` for Git over SSH. Disable it with `service.ssh.enabled=false`.

## Storage and database

Gitea stores repositories, configuration and the embedded SQLite database under
`/data`. The default `extraEnv` sets `GITEA__database__DB_TYPE=sqlite3` and
`GITEA__server__ROOT_URL`. Set `GITEA__server__ROOT_URL` to the public address
so links and clone URLs resolve correctly, and override the
`GITEA__database__*` variables to use an external PostgreSQL or MySQL server.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-gitea kymelio/gitea
```

### OCI registry

```sh
helm install my-gitea oci://ghcr.io/kymeliodev/kymelio-helm/gitea --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-gitea
```

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-gitea kymelio/gitea --reuse-values
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `docker.io/gitea/gitea` | Container image repository |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `3000` | HTTP service port |
| service.portName | string | `http` | HTTP port name |
| service.ssh.enabled | bool | `true` | Expose the Git SSH port |
| service.ssh.port | int | `22` | SSH service port |
| service.ssh.portName | string | `ssh` | SSH port name |
| persistence.enabled | bool | `true` | Enable persistent storage for /data |
| persistence.size | string | `8Gi` | Persistent volume size |
| persistence.mountPath | string | `/data` | Mount path for Gitea data |
| extraEnv | list | sqlite3, root url | Extra environment variables |
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

Gitea exposes a built in Prometheus endpoint at `/metrics` on the HTTP port
(`3000`). Set `metrics.enabled=true` to inject `GITEA__metrics__ENABLED=true`
and let Gitea serve the endpoint. Enable the ServiceMonitor to have Prometheus
scrape it:

```sh
helm install my-gitea kymelio/gitea \
  --set metrics.enabled=true \
  --set metrics.serviceMonitor.enabled=true
```

Restrict the endpoint to authorized scrapers by setting a token, which renders
`GITEA__metrics__TOKEN`:

```sh
helm install my-gitea kymelio/gitea \
  --set metrics.enabled=true \
  --set metrics.token=changeme
```

### Native configuration

Gitea reads its configuration from `GITEA__<section>__<KEY>` environment
variables. Tune any section through `extraEnv`, for example to point at an
external PostgreSQL server and raise upload limits:

```yaml
extraEnv:
  - name: GITEA__database__DB_TYPE
    value: postgres
  - name: GITEA__database__HOST
    value: postgres.db.svc:5432
  - name: GITEA__database__NAME
    value: gitea
  - name: GITEA__server__ROOT_URL
    value: https://git.example.com/
  - name: GITEA__attachment__MAX_SIZE
    value: "32"
```

The generic `configuration` surface remains available to mount an inline
`app.ini` through a ConfigMap when you prefer a file over environment variables.

### TLS

Gitea is normally fronted by an Ingress or a reverse proxy that terminates TLS,
so the chart does not serve TLS from the container. Enable `ingress` and attach
a certificate Secret there:

```yaml
ingress:
  enabled: true
  className: nginx
  hosts:
    - host: git.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: gitea-tls
      hosts:
        - git.example.com
```
