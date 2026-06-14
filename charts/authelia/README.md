# authelia

Authentication and authorization server providing single sign-on and two-factor
authentication, deployed as a stateless Deployment.

The chart renders a minimal Authelia configuration into a ConfigMap and mounts
it at `/config/configuration.yml`. The default configuration uses a file
authentication backend and a local SQLite storage backend, which is suitable for
evaluation. The JWT, session and storage encryption secrets are kept in a Secret
managed by this chart and injected through environment variables.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-authelia kymelio/authelia
```

### OCI registry

```sh
helm install my-authelia oci://ghcr.io/kymeliodev/kymelio-helm/authelia --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-authelia
```

## Upgrading

Review the chart version change and your overridden values before upgrading. The
generated secrets are preserved across upgrades when you keep the `auth` values
empty and reuse the release Secret.

```sh
helm upgrade my-authelia kymelio/authelia
```

## Configuration

The full Authelia configuration is exposed under the `authelia` value and
rendered verbatim into `configuration.yml`. Override individual keys to point at
external backends, for example an LDAP authentication backend or a PostgreSQL
storage backend:

```yaml
authelia:
  session:
    cookies:
      - domain: example.com
        authelia_url: https://auth.example.com
```

The container is started with `--config=/config/configuration.yml`. The JWT,
session and storage encryption secrets are supplied through
`AUTHELIA_JWT_SECRET`, `AUTHELIA_SESSION_SECRET` and
`AUTHELIA_STORAGE_ENCRYPTION_KEY`.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `docker.io/authelia/authelia` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| auth.jwtSecret | string | `""` | JWT secret, generated when empty |
| auth.sessionSecret | string | `""` | Session secret, generated when empty |
| auth.storageEncryptionKey | string | `""` | Storage encryption key, generated when empty |
| auth.existingSecret | string | `""` | Use an existing Secret for the runtime secrets |
| authelia | object | minimal config | Authelia configuration rendered into configuration.yml |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `9091` | Service port |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| podDisruptionBudget.enabled | bool | `false` | Enable a PodDisruptionBudget |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| extraEnv | list | `[]` | Extra environment variables passed to the container |
