# forgejo

A Helm chart for Forgejo, a self hosted lightweight software forge for Git
hosting, issue tracking, pull requests and CI.

## Ports

The StatefulSet exposes two ports:

- `http` on `3000` for the web UI and HTTP Git access.
- `ssh` on `22` for Git over SSH. Disable it with `service.ssh.enabled=false`.

## Storage and database

Forgejo stores repositories, configuration and the embedded SQLite database
under `/data`. The default `extraEnv` sets `FORGEJO__database__DB_TYPE=sqlite3`
and `FORGEJO__server__DOMAIN`. Override the `FORGEJO__database__*` variables to
point Forgejo at an external PostgreSQL or MySQL server.

## Administrator account

Set `admin.create=true` to bootstrap an initial administrator on first start.
The password is taken from a generated Secret, from `admin.password`, or from an
`admin.existingSecret`.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-forgejo kymelio/forgejo
```

### OCI registry

```sh
helm install my-forgejo oci://ghcr.io/kymeliodev/kymelio-helm/forgejo --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-forgejo
```

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-forgejo kymelio/forgejo --reuse-values
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `codeberg.org/forgejo/forgejo` | Container image repository |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| admin.create | bool | `false` | Create an initial administrator on first start |
| admin.username | string | `forgejo_admin` | Administrator user name |
| admin.email | string | `admin@example.com` | Administrator email |
| admin.password | string | `""` | Administrator password, randomly generated when empty |
| admin.existingSecret | string | `""` | Existing Secret holding the admin password |
| domain | string | `forgejo.example.com` | Public domain advertised by Forgejo |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `3000` | HTTP service port |
| service.portName | string | `http` | HTTP port name |
| service.ssh.enabled | bool | `true` | Expose the Git SSH port |
| service.ssh.port | int | `22` | SSH service port |
| service.ssh.portName | string | `ssh` | SSH port name |
| persistence.enabled | bool | `true` | Enable persistent storage for /data |
| persistence.size | string | `8Gi` | Persistent volume size |
| persistence.mountPath | string | `/data` | Mount path for Forgejo data |
| extraEnv | list | sqlite3, domain | Extra environment variables |
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

Forgejo exposes a built in Prometheus endpoint at `/metrics` on the HTTP port
(`3000`). Set `metrics.enabled=true` to inject `FORGEJO__metrics__ENABLED=true`
and let Forgejo serve the endpoint. Enable the ServiceMonitor to have Prometheus
scrape it:

```sh
helm install my-forgejo kymelio/forgejo \
  --set metrics.enabled=true \
  --set metrics.serviceMonitor.enabled=true
```

Restrict the endpoint to authorized scrapers by setting a token, which renders
`FORGEJO__metrics__TOKEN`:

```sh
helm install my-forgejo kymelio/forgejo \
  --set metrics.enabled=true \
  --set metrics.token=changeme
```

### Native configuration

Forgejo reads its configuration from `FORGEJO__<section>__<KEY>` environment
variables. Tune any section through `extraEnv`, for example to use an external
PostgreSQL server and set the public domain:

```yaml
extraEnv:
  - name: FORGEJO__database__DB_TYPE
    value: postgres
  - name: FORGEJO__database__HOST
    value: postgres.db.svc:5432
  - name: FORGEJO__database__NAME
    value: forgejo
  - name: FORGEJO__server__DOMAIN
    value: git.example.com
  - name: FORGEJO__server__ROOT_URL
    value: https://git.example.com/
```

The generic `configuration` surface remains available to mount an inline
`app.ini` through a ConfigMap when you prefer a file over environment variables.

### TLS

Forgejo is normally fronted by an Ingress or a reverse proxy that terminates
TLS, so the chart does not serve TLS from the container. Enable `ingress` and
attach a certificate Secret there:

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
    - secretName: forgejo-tls
      hosts:
        - git.example.com
```
