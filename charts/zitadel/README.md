# zitadel

Cloud native identity and access management platform, deployed as a stateless
Deployment.

The container starts with `start-from-init`, which initialises the database on
first run and then starts the server. ZITADEL does not bundle a database, so a
reachable PostgreSQL instance is required and is configured through
`externalDatabase`. TLS is terminated outside the pod, so the server runs with
`--tlsMode disabled` and expects to sit behind an ingress or proxy.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-zitadel kymelio/zitadel
```

### OCI registry

```sh
helm install my-zitadel oci://ghcr.io/kymeliodev/kymelio-helm/zitadel --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-zitadel
```

## Upgrading

Review the chart version change and your overridden values before upgrading. The
generated master key is preserved across upgrades when you keep `auth.masterKey`
empty and reuse the release Secret.

```sh
helm upgrade my-zitadel kymelio/zitadel
```

## Master key

ZITADEL encrypts stored secrets with a master key that must be exactly 32
characters. When `auth.masterKey` is empty a random 32 character value is
generated and stored in a Secret. The value is read at runtime from
`ZITADEL_MASTERKEY` because the server is started with `--masterkeyFromEnv`.

## External PostgreSQL

Point the chart at your database and supply the user password through
`extraEnv`:

```yaml
externalDatabase:
  host: postgresql
  port: 5432
  database: zitadel
  user: zitadel
  sslMode: disable
extraEnv:
  - name: ZITADEL_DATABASE_POSTGRES_USER_PASSWORD
    valueFrom:
      secretKeyRef:
        name: postgresql
        key: password
  - name: ZITADEL_DATABASE_POSTGRES_ADMIN_USERNAME
    value: postgres
  - name: ZITADEL_DATABASE_POSTGRES_ADMIN_PASSWORD
    valueFrom:
      secretKeyRef:
        name: postgresql
        key: postgres-password
```

The connection details are passed through `ZITADEL_DATABASE_POSTGRES_HOST`,
`ZITADEL_DATABASE_POSTGRES_PORT`, `ZITADEL_DATABASE_POSTGRES_DATABASE`,
`ZITADEL_DATABASE_POSTGRES_USER_USERNAME` and
`ZITADEL_DATABASE_POSTGRES_USER_SSL_MODE`.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `ghcr.io/zitadel/zitadel` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| auth.masterKey | string | `""` | Master key, exactly 32 characters, generated when empty |
| auth.existingSecret | string | `""` | Use an existing Secret for the master key |
| auth.secretKeys.masterKeyKey | string | `master-key` | Secret key holding the master key |
| externalDatabase.host | string | `postgresql` | PostgreSQL host |
| externalDatabase.port | int | `5432` | PostgreSQL port |
| externalDatabase.database | string | `zitadel` | PostgreSQL database name |
| externalDatabase.user | string | `zitadel` | PostgreSQL application user |
| externalDatabase.sslMode | string | `disable` | PostgreSQL SSL mode |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `8080` | Service port |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| podDisruptionBudget.enabled | bool | `false` | Enable a PodDisruptionBudget |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| extraEnv | list | `[]` | Extra environment variables, used for the database password |
