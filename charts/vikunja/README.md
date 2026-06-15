# vikunja

[Vikunja](https://vikunja.io) is a self hosted to-do and project management
application. It is deployed here as a StatefulSet.

By default Vikunja runs standalone on a SQLite database stored on the persistent
volume, so no external database is required. An external PostgreSQL or MySQL
database can be configured instead.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-vikunja kymelio/vikunja
```

### OCI registry

```sh
helm install my-vikunja oci://ghcr.io/kymeliodev/kymelio-helm/vikunja --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-vikunja
```

## Storage

Uploaded files and, by default, the SQLite database live under
`/app/vikunja/files` (`persistence.mountPath`) on a PersistentVolumeClaim.

## External database

To use an external database instead of SQLite, set `database.type` to `postgres`
or `mysql` and provide connection details:

```yaml
database:
  type: postgres
externalDatabase:
  host: postgresql:5432
  database: vikunja
  user: vikunja
  password: changeme
```

## Secrets

`VIKUNJA_SERVICE_JWTSECRET` is generated on first install and stored in the
release Secret. It is reused on upgrade so sessions stay valid. To manage it
yourself, set `auth.jwtSecret`, or create a Secret with the key `jwt-secret` and
set `auth.existingSecret`.

## Upgrading

Review the chart version change and your overridden values before upgrading.

```sh
helm upgrade my-vikunja kymelio/vikunja
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `docker.io/vikunja/vikunja` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| vikunja.publicUrl | string | `http://localhost:3456/` | Public URL the API and frontend are served from |
| auth.jwtSecret | string | `""` | Fixed JWT secret, generated when empty |
| auth.existingSecret | string | `""` | Use an existing Secret for the JWT secret |
| auth.secretKeys.jwtSecretKey | string | `jwt-secret` | Secret key holding the JWT secret |
| database.type | string | `sqlite` | Database backend: sqlite, postgres or mysql |
| externalDatabase.host | string | `postgresql:5432` | External database host and port |
| externalDatabase.database | string | `vikunja` | External database name |
| externalDatabase.user | string | `vikunja` | External database user |
| externalDatabase.password | string | `vikunja` | External database password |
| persistence.enabled | bool | `true` | Enable a PersistentVolumeClaim |
| persistence.size | string | `8Gi` | Size of the PersistentVolumeClaim |
| persistence.mountPath | string | `/app/vikunja/files` | Path where files and SQLite data are stored |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `3456` | Service port |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| podDisruptionBudget.enabled | bool | `false` | Enable a PodDisruptionBudget |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Enable the built in Prometheus metrics endpoint (sets `VIKUNJA_SERVICE_ENABLEMETRICS=true`) |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| metrics.serviceMonitor.interval | string | `30s` | Scrape interval |
| metrics.serviceMonitor.scrapeTimeout | string | `10s` | Scrape timeout |
| metrics.serviceMonitor.labels | object | `{}` | Extra labels for the ServiceMonitor |
| extraEnv | list | `[]` | Extra environment variables passed to the container |

## Configuration

Vikunja is configured through `VIKUNJA_<SECTION>_<SETTING>` environment
variables. The chart wires the core settings (public URL, database, JWT secret,
file path) and exposes `extraEnv` for everything else.

```yaml
vikunja:
  publicUrl: https://tasks.example.com/
extraEnv:
  - name: VIKUNJA_SERVICE_TIMEZONE
    value: Europe/Zurich
  - name: VIKUNJA_MAILER_ENABLED
    value: "true"
  - name: VIKUNJA_MAILER_HOST
    value: smtp.example.com
  - name: VIKUNJA_DEFAULTSETTINGS_AVATAR_PROVIDER
    value: initials
```

### Metrics

Vikunja serves Prometheus metrics from the API itself. Setting
`metrics.enabled` exports `VIKUNJA_SERVICE_ENABLEMETRICS=true`; the endpoint is
exposed on the API port (`3456`) at `/metrics` (also reachable at
`/api/v1/metrics`). The ServiceMonitor then scrapes the `http` port on the
`/metrics` path.

```yaml
metrics:
  enabled: true
  serviceMonitor:
    enabled: true
```

When running more than one replica, enable a shared Redis keyvalue backend so
metrics are aggregated across nodes (`VIKUNJA_KEYVALUE_TYPE=redis` and the
matching `VIKUNJA_REDIS_*` variables via `extraEnv`). The ServiceMonitor
requires the Prometheus Operator CRDs.

### Ingress and TLS

Vikunja serves plain HTTP on port `3456`. Terminate TLS at an ingress
controller or reverse proxy rather than on the application. Set
`vikunja.publicUrl` to the external HTTPS URL and enable `ingress` with
`ingress.tls`.
