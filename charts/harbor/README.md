# harbor

A Helm chart for the Harbor core service. Harbor is an open source cloud native
registry that stores, signs and scans container images and OCI artifacts.

## Scope and external dependencies

This chart deploys only the `harbor-core` component. Harbor is a multi service
system and the core service cannot run on its own. Before the core becomes
healthy you must provide the following components and wire them in through
`extraEnv`:

- External PostgreSQL database for the Harbor metadata.
- External Redis instance for caching and job state.
- The Harbor registry (distribution) service for blob storage.
- The Harbor jobservice, portal and, when enabled, the Trivy scanner and notary
  services.

Use `externalDatabase` and `externalRedis` in `values.yaml` to record the
endpoints, and pass the matching configuration variables (for example
`POSTGRESQL_HOST`, `_REDIS_URL_CORE`, `REGISTRY_URL`, `CORE_SECRET`) through
`extraEnv`.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-harbor kymelio/harbor
```

### OCI registry

```sh
helm install my-harbor oci://ghcr.io/kymeliodev/kymelio-helm/harbor --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-harbor
```

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-harbor kymelio/harbor --reuse-values
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `docker.io/goharbor/harbor-core` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| auth.adminPassword | string | `""` | Admin password, randomly generated when empty |
| auth.existingSecret | string | `""` | Existing Secret holding the admin password |
| auth.secretKeys.passwordKey | string | `HARBOR_ADMIN_PASSWORD` | Key inside the Secret for the admin password |
| externalDatabase.host | string | `""` | External PostgreSQL host required by the core |
| externalRedis.host | string | `""` | External Redis host required by the core |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `8080` | Service port |
| service.portName | string | `http` | Service port name |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| podDisruptionBudget.enabled | bool | `false` | Enable a PodDisruptionBudget |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Expose the harbor-core Prometheus endpoint and publish the metrics port |
| metrics.port | int | `8001` | Port harbor-core serves metrics on (METRIC_PORT) |
| metrics.path | string | `/metrics` | Path harbor-core serves metrics on (METRIC_PATH) |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| extraEnv | list | `[]` | Extra environment variables, used to wire external services |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot, uid 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |

## Configuration

### Metrics

harbor-core exposes a built in Prometheus endpoint. Set `metrics.enabled=true`
to inject `METRIC_ENABLE=true`, `METRIC_PORT=8001` and `METRIC_PATH=/metrics`,
publish the `metrics` port (`8001`) on the Service and let harbor-core serve
`/metrics` there. Enable the ServiceMonitor so Prometheus scrapes that port:

```sh
helm install my-harbor kymelio/harbor \
  --set metrics.enabled=true \
  --set metrics.serviceMonitor.enabled=true
```

### Native configuration

harbor-core is configured through environment variables. Wire the external
services and tune the core through `extraEnv`, for example:

```yaml
extraEnv:
  - name: POSTGRESQL_HOST
    value: postgres.db.svc
  - name: POSTGRESQL_PORT
    value: "5432"
  - name: _REDIS_URL_CORE
    value: redis://redis.cache.svc:6379/0
  - name: REGISTRY_URL
    value: http://harbor-registry:5000
  - name: EXT_ENDPOINT
    value: https://harbor.example.com
  - name: LOG_LEVEL
    value: info
```

The generic `configuration` surface remains available to mount an inline config
file through a ConfigMap when a component requires one.

### TLS

harbor-core itself serves plain HTTP. TLS for Harbor is terminated by the Harbor
portal or by the Ingress in front of the deployment, so enable `ingress` and
attach a certificate Secret there:

```yaml
ingress:
  enabled: true
  className: nginx
  hosts:
    - host: harbor.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: harbor-tls
      hosts:
        - harbor.example.com
```
