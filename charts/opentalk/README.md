# opentalk

Helm chart for the [OpenTalk](https://opentalk.eu/) controller, the core backend
service of the OpenTalk self hosted video conferencing platform.

The chart deploys the controller as a stateless Deployment. The controller holds
no local state and requires several external services.

## Image

OpenTalk publishes the controller image as `docker.io/opentalk/controller`. This
chart uses that image. Pin `image.tag` to a fixed release for reproducible
deployments and override `image.repository` if you mirror the image into a
private registry.

## Required external services

This chart does not bundle any backing services. Provide the following and pass
their connection settings through values:

- PostgreSQL, via `externalDatabase`. The password is read from the Secret named
  in `externalDatabase.existingSecret`.
- Redis, via `externalRedis`, used for session and signalling state.
- Keycloak, via `externalKeycloak`, used as the OpenID Connect provider. Set
  `externalKeycloak.issuerUrl` and `externalKeycloak.clientId`.

The controller also authenticates companion OpenTalk services with a shared
service key, stored in a Secret managed by this chart or provided through
`auth.existingSecret`.

## Install

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-opentalk kymelio/opentalk \
  --set externalDatabase.host=postgres.example \
  --set externalDatabase.existingSecret=opentalk-db \
  --set externalRedis.host=redis.example \
  --set externalKeycloak.issuerUrl=https://keycloak.example/realms/opentalk
```

## Uninstall

```sh
helm uninstall my-opentalk
```

## Configuration

### Application settings

The controller is configured with a TOML file whose fields can be overridden by
environment variables prefixed with `OPENTALK_CTRL_`, where nested fields are
separated by two underscores. The chart already sets the database, Redis,
Keycloak and HTTP settings this way. Add further overrides through `extraEnv`:

```yaml
extraEnv:
  - name: OPENTALK_CTRL_HTTP__CORS__ALLOWED_ORIGIN
    value: "https://meet.example.com"
  - name: OPENTALK_CTRL_LOGGING__DEFAULT_DIRECTIVES
    value: "info"
```

To supply a full `controller.toml`, render it with `configuration` and mount it
where the controller reads its config.

### TLS

The controller serves plain HTTP on port 8080 and does not terminate TLS itself.
Run it behind an ingress controller or reverse proxy that terminates TLS for the
public host name, and configure `ingress.tls` accordingly.

### Metrics

The OpenTalk controller serves a `/metrics` endpoint in OpenMetrics format on the
HTTP service port. By default that endpoint refuses every connection; it only
responds to source addresses listed in the controller `[metrics] allowlist`.

When `metrics.enabled` is set, the chart sets
`OPENTALK_CTRL_METRICS__ALLOWLIST` to the CIDRs in `metrics.allowlist`, and the
ServiceMonitor scrapes the HTTP port at `metrics.path` (requires the Prometheus
Operator CRDs). Set the allowlist to the networks your Prometheus scrapes from,
for example the pod or node CIDRs:

```yaml
metrics:
  enabled: true
  path: /metrics
  allowlist:
    - 10.0.0.0/8
  serviceMonitor:
    enabled: true
    interval: 30s
    labels:
      release: kube-prometheus-stack
```

If `metrics.allowlist` is left empty the controller keeps its default and denies
all scrape requests, so the endpoint returns no data.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `docker.io/opentalk/controller` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| auth.serviceKey | string | `""` | Service authentication key, generated when empty |
| auth.existingSecret | string | `""` | Existing Secret holding the service key |
| auth.secretKeys.serviceKey | string | `service-key` | Key in the Secret holding the service key |
| externalDatabase.host | string | `""` | External PostgreSQL host |
| externalDatabase.port | int | `5432` | External PostgreSQL port |
| externalDatabase.database | string | `opentalk` | External database name |
| externalDatabase.user | string | `opentalk` | External database user |
| externalDatabase.existingSecret | string | `""` | Secret holding the database password (required) |
| externalDatabase.existingSecretPasswordKey | string | `db-password` | Key in the database Secret |
| externalRedis.host | string | `""` | External Redis host |
| externalRedis.port | int | `6379` | External Redis port |
| externalKeycloak.issuerUrl | string | `""` | OpenID Connect issuer URL |
| externalKeycloak.clientId | string | `opentalk` | OpenID Connect client id |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `8080` | Service port, named http |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| podDisruptionBudget.enabled | bool | `false` | Enable a PodDisruptionBudget |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Configure the controller metrics allowlist and scrape /metrics |
| metrics.path | string | `/metrics` | HTTP path of the controller metrics endpoint |
| metrics.allowlist | list | `[]` | Source CIDRs allowed to scrape /metrics (OPENTALK_CTRL_METRICS__ALLOWLIST) |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor scraping the HTTP port |
| extraEnv | list | `[]` | Extra environment variables passed to the container |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsUser 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |
