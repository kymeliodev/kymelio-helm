# outline

[Outline](https://github.com/outline/outline) is a collaborative team knowledge
base and wiki. It is deployed here as a stateless Deployment.

Outline requires external PostgreSQL and Redis services. This chart does not
bundle either one. Provide reachable instances through the `externalDatabase`
and `externalRedis` values before installing.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-outline kymelio/outline
```

### OCI registry

```sh
helm install my-outline oci://ghcr.io/kymeliodev/kymelio-helm/outline --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-outline
```

## Required external services

Outline stores all data in PostgreSQL and uses Redis for queues and websockets.
Point the chart at your own instances:

```yaml
outline:
  url: https://wiki.example.com
externalDatabase:
  url: postgres://outline:password@postgresql:5432/outline
  sslMode: disable
externalRedis:
  url: redis://redis:6379
```

## Secrets

`SECRET_KEY` and `UTILS_SECRET` are generated on first install and stored in the
release Secret. They are reused on upgrade so they stay stable. To manage them
yourself, create a Secret with the keys `secret-key` and `utils-secret` and set
`auth.existingSecret` to its name.

## Upgrading

Review the chart version change and your overridden values before upgrading.

```sh
helm upgrade my-outline kymelio/outline
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `docker.io/outlinewiki/outline` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| outline.url | string | `http://localhost:3000` | Public URL Outline is served from |
| auth.existingSecret | string | `""` | Use an existing Secret for application secrets |
| auth.secretKeys.secretKey | string | `secret-key` | Secret key holding SECRET_KEY |
| auth.secretKeys.utilsSecretKey | string | `utils-secret` | Secret key holding UTILS_SECRET |
| externalDatabase.url | string | `postgres://...` | PostgreSQL connection string (DATABASE_URL) |
| externalDatabase.sslMode | string | `disable` | PostgreSQL SSL mode (PGSSLMODE) |
| externalRedis.url | string | `redis://redis:6379` | Redis connection string (REDIS_URL) |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `3000` | Service port |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| podDisruptionBudget.enabled | bool | `false` | Enable a PodDisruptionBudget |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| extraEnv | list | `[]` | Extra environment variables passed to the container |
