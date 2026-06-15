# backstage

Backstage developer portal for cataloging software and services, deployed as a
stateless Deployment.

Backstage requires an external PostgreSQL database for its catalog and plugin
data. This chart does not provision a database. Point the `postgresql` values at
a running PostgreSQL instance before installing.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-backstage kymelio/backstage \
  --set postgresql.host=postgresql.data.svc.cluster.local \
  --set postgresql.user=backstage
```

### OCI registry

```sh
helm install my-backstage oci://ghcr.io/kymeliodev/kymelio-helm/backstage --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-backstage
```

## Upgrading

Review the chart version change and your overridden values before upgrading. A
generated database password and backend secret are preserved across upgrades
when you keep `postgresql.password` and `backend.secret` empty and reuse the
release Secret.

```sh
helm upgrade my-backstage kymelio/backstage --reuse-values
```

## Database connection

The backend reads the following environment variables, populated from the
chart values and the managed Secret:

- `POSTGRES_HOST` from `postgresql.host`
- `POSTGRES_PORT` from `postgresql.port`
- `POSTGRES_USER` from `postgresql.user`
- `POSTGRES_PASSWORD` from the Secret
- `BACKEND_SECRET` from the Secret, used to sign service to service tokens

Provide your own credentials Secret with `existingSecret`, supplying the keys
named in `secretKeys`.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `ghcr.io/backstage/backstage` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| postgresql.host | string | `postgresql` | External PostgreSQL host |
| postgresql.port | int | `5432` | External PostgreSQL port |
| postgresql.user | string | `backstage` | External PostgreSQL user |
| postgresql.password | string | `""` | Database password, generated when empty |
| backend.secret | string | `""` | Backend signing secret, generated when empty |
| existingSecret | string | `""` | Use an existing Secret for credentials |
| secretKeys.postgresPasswordKey | string | `postgres-password` | Secret key holding the database password |
| secretKeys.backendSecretKey | string | `backend-secret` | Secret key holding the backend secret |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `7007` | Service port |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| podDisruptionBudget.enabled | bool | `false` | Enable a PodDisruptionBudget |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |
