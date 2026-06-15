# keycloak

Open source identity and access management, deployed as a stateless Deployment.

By default the chart starts Keycloak in development mode (`start-dev`) so it
installs without an external database. This is not suitable for production.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-keycloak kymelio/keycloak
```

### OCI registry

```sh
helm install my-keycloak oci://ghcr.io/kymeliodev/kymelio-helm/keycloak --version 0.1.1
```

## Uninstall

```sh
helm uninstall my-keycloak
```

## Upgrading

Review the chart version change and your overridden values before upgrading. A
generated password is preserved across upgrades when you keep `auth.adminPassword`
empty and reuse the release Secret.

```sh
helm upgrade my-keycloak kymelio/keycloak
```

## Production mode

Set `production=true` to start Keycloak with `start`. Production mode requires an
external database and a hostname, supplied through `extraEnv`, for example:

```yaml
production: true
extraEnv:
  - name: KC_DB
    value: postgres
  - name: KC_DB_URL
    value: jdbc:postgresql://postgresql:5432/keycloak
  - name: KC_DB_USERNAME
    value: keycloak
  - name: KC_DB_PASSWORD
    value: changeme
  - name: KC_HOSTNAME
    value: keycloak.example.com
```

## Configuration

### Metrics

Keycloak exposes Micrometer metrics in Prometheus format at `/metrics` on the
management interface (port 9000). The management interface is already active
because the chart enables health checks. Set `metrics.enabled` to true to set
`KC_METRICS_ENABLED` and expose port 9000 on the container and Service. Enable
`metrics.serviceMonitor.enabled` to scrape it with the Prometheus Operator.

```yaml
metrics:
  enabled: true
  serviceMonitor:
    enabled: true
    interval: 30s
```

### TLS

Keycloak terminates TLS itself. Provide a Secret holding a PEM certificate and
key, and Keycloak reads them through `KC_HTTPS_CERTIFICATE_FILE` and
`KC_HTTPS_CERTIFICATE_KEY_FILE`. The HTTPS port (8443) is added to the container
and Service.

```yaml
tls:
  enabled: true
  existingSecret: keycloak-tls
  certFilename: tls.crt
  keyFilename: tls.key
  port: 8443
```

### Native configuration

Pass any Keycloak server option as an environment variable through `extraEnv`,
for example to tune the cache or hostname:

```yaml
extraEnv:
  - name: KC_CACHE
    value: ispn
  - name: KC_HOSTNAME_STRICT
    value: "false"
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `quay.io/keycloak/keycloak` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| auth.adminUser | string | `admin` | Initial admin user created on first start |
| auth.adminPassword | string | `""` | Admin password, generated when empty |
| auth.existingSecret | string | `""` | Use an existing Secret for credentials |
| auth.secretKeys.passwordKey | string | `admin-password` | Secret key holding the password |
| production | bool | `false` | Start in production mode, requires an external database |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `8080` | Service port |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| podDisruptionBudget.enabled | bool | `false` | Enable a PodDisruptionBudget |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Enable the built-in /metrics endpoint on the management port |
| metrics.port | int | `9000` | Management interface port serving /metrics and /health |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| metrics.serviceMonitor.path | string | `/metrics` | Metrics path on the management port |
| tls.enabled | bool | `false` | Terminate TLS in Keycloak using a mounted Secret |
| tls.existingSecret | string | `""` | Secret holding the certificate and key |
| tls.port | int | `8443` | HTTPS port served by Keycloak |
| extraEnv | list | `[]` | Extra environment variables, required for production mode |
