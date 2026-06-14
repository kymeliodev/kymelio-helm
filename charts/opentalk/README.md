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
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsUser 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |
