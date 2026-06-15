# plausible

[Plausible](https://github.com/plausible/community-edition) is a privacy
friendly web analytics platform. It is deployed here as a stateless Deployment.

Plausible requires external PostgreSQL and ClickHouse services. This chart does
not bundle either one. Provide reachable instances through the
`externalDatabase` and `externalClickhouse` values before installing.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-plausible kymelio/plausible
```

### OCI registry

```sh
helm install my-plausible oci://ghcr.io/kymeliodev/kymelio-helm/plausible --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-plausible
```

## Required external services

Plausible stores application data in PostgreSQL and analytics events in
ClickHouse. Point the chart at your own instances:

```yaml
plausible:
  baseUrl: https://analytics.example.com
externalDatabase:
  url: postgres://plausible:password@postgresql:5432/plausible
externalClickhouse:
  url: http://clickhouse:8123/plausible_events_db
```

The container runs database migrations on start, so both services must be
reachable when the pod boots.

## Secrets

`SECRET_KEY_BASE` is a 64 character value generated on first install and stored
in the release Secret. It is reused on upgrade so it stays stable. To manage it
yourself, set `auth.secretKeyBase`, or create a Secret with the key
`secret-key-base` and set `auth.existingSecret`.

## Upgrading

Review the chart version change and your overridden values before upgrading.

```sh
helm upgrade my-plausible kymelio/plausible
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `ghcr.io/plausible/community-edition` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| plausible.baseUrl | string | `http://localhost:8000` | Public URL Plausible is served from (BASE_URL) |
| auth.secretKeyBase | string | `""` | Fixed 64 character secret, generated when empty |
| auth.existingSecret | string | `""` | Use an existing Secret for SECRET_KEY_BASE |
| auth.secretKeys.secretKeyBaseKey | string | `secret-key-base` | Secret key holding SECRET_KEY_BASE |
| externalDatabase.url | string | `postgres://...` | PostgreSQL connection string (DATABASE_URL) |
| externalClickhouse.url | string | `http://clickhouse:8123/...` | ClickHouse connection string (CLICKHOUSE_DATABASE_URL) |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `8000` | Service port |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| podDisruptionBudget.enabled | bool | `false` | Enable a PodDisruptionBudget |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Enable the built in PromEx Prometheus endpoint (sets `PROMEX_DISABLED=false`) |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| metrics.serviceMonitor.interval | string | `30s` | Scrape interval |
| metrics.serviceMonitor.scrapeTimeout | string | `10s` | Scrape timeout |
| metrics.serviceMonitor.labels | object | `{}` | Extra labels for the ServiceMonitor |
| extraEnv | list | `[]` | Extra environment variables passed to the container |

## Configuration

Plausible Community Edition is configured through environment variables. The
chart wires `BASE_URL`, `SECRET_KEY_BASE`, `DATABASE_URL` and
`CLICKHOUSE_DATABASE_URL`, and exposes `extraEnv` for the rest, including SMTP,
registration and TOTP settings.

```yaml
plausible:
  baseUrl: https://analytics.example.com
extraEnv:
  - name: DISABLE_REGISTRATION
    value: "true"
  - name: MAILER_EMAIL
    value: plausible@example.com
  - name: SMTP_HOST_ADDR
    value: smtp.example.com
  - name: SMTP_HOST_PORT
    value: "587"
```

### Metrics

Plausible exposes Prometheus metrics through the built in PromEx integration.
Setting `metrics.enabled` exports `PROMEX_DISABLED=false`; PromEx mounts its
plug on the main Phoenix endpoint, so metrics are served on the application HTTP
port (`8000`) at `/metrics`. The ServiceMonitor scrapes the `http` port on that
path.

```yaml
metrics:
  enabled: true
  serviceMonitor:
    enabled: true
```

The ServiceMonitor requires the Prometheus Operator CRDs. Because the endpoint
shares the application port, restrict access to `/metrics` at your ingress or
network policy if the service is publicly reachable.

### Ingress and TLS

Plausible serves plain HTTP on port `8000` and expects TLS to be terminated by
an ingress controller or reverse proxy. Set `plausible.baseUrl` to the external
HTTPS URL and enable `ingress` with `ingress.tls` rather than configuring TLS on
the application.
