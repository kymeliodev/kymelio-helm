# authentik

Open source identity provider for SSO and access management, deployed as a
stateless Deployment running the authentik server process.

authentik does not bundle its data stores. A reachable PostgreSQL database and a
Redis instance are required and are configured through `externalDatabase` and
`externalRedis`.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-authentik kymelio/authentik
```

### OCI registry

```sh
helm install my-authentik oci://ghcr.io/kymeliodev/kymelio-helm/authentik --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-authentik
```

## Upgrading

Review the chart version change and your overridden values before upgrading. The
generated secret key is preserved across upgrades when you keep `auth.secretKey`
empty and reuse the release Secret.

```sh
helm upgrade my-authentik kymelio/authentik
```

## External PostgreSQL and Redis

Point the chart at your data stores and supply the database password through
`extraEnv`:

```yaml
externalDatabase:
  host: postgresql
  port: 5432
  database: authentik
  user: authentik
externalRedis:
  host: redis
  port: 6379
extraEnv:
  - name: AUTHENTIK_POSTGRESQL__PASSWORD
    valueFrom:
      secretKeyRef:
        name: postgresql
        key: password
```

The host values are passed to authentik through `AUTHENTIK_POSTGRESQL__HOST` and
`AUTHENTIK_REDIS__HOST`. The secret key is read from `AUTHENTIK_SECRET_KEY`,
which is sourced from a Secret managed by this chart.

## Configuration

### Metrics

The authentik server exposes Prometheus metrics at `/metrics` on a dedicated
port (9300) that requires no authentication. Set `metrics.enabled` to true to
add the port to the container and Service, and enable
`metrics.serviceMonitor.enabled` to scrape it with the Prometheus Operator:

```yaml
metrics:
  enabled: true
  serviceMonitor:
    enabled: true
    interval: 30s
```

### Native configuration

authentik is configured through `AUTHENTIK_*` environment variables. Pass any
of them through `extraEnv`, for example to set the error reporting and email
options:

```yaml
extraEnv:
  - name: AUTHENTIK_ERROR_REPORTING__ENABLED
    value: "false"
  - name: AUTHENTIK_EMAIL__HOST
    value: smtp.example.com
  - name: AUTHENTIK_EMAIL__PORT
    value: "587"
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `ghcr.io/goauthentik/server` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| auth.secretKey | string | `""` | Value for AUTHENTIK_SECRET_KEY, generated when empty |
| auth.existingSecret | string | `""` | Use an existing Secret for the secret key |
| auth.secretKeys.secretKeyKey | string | `secret-key` | Secret key holding the value |
| externalDatabase.host | string | `postgresql` | PostgreSQL host |
| externalDatabase.port | int | `5432` | PostgreSQL port |
| externalDatabase.database | string | `authentik` | PostgreSQL database name |
| externalDatabase.user | string | `authentik` | PostgreSQL user |
| externalRedis.host | string | `redis` | Redis host |
| externalRedis.port | int | `6379` | Redis port |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `9000` | Service port |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| podDisruptionBudget.enabled | bool | `false` | Enable a PodDisruptionBudget |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Expose the built-in /metrics endpoint on port 9300 |
| metrics.port | int | `9300` | Port serving the metrics endpoint |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| metrics.serviceMonitor.path | string | `/metrics` | Metrics path scraped by the ServiceMonitor |
| extraEnv | list | `[]` | Extra environment variables, used for the database password |
