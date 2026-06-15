# paperless-ngx

[Paperless-ngx](https://github.com/paperless-ngx/paperless-ngx) is a document
management system that indexes, OCRs and archives your scanned paperwork. It is
deployed here as a StatefulSet.

Paperless-ngx requires an external Redis service for its task queue. This chart
does not bundle Redis. The document database runs on SQLite stored on the
persistent volume, so no external database is required.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-paperless kymelio/paperless-ngx
```

### OCI registry

```sh
helm install my-paperless oci://ghcr.io/kymeliodev/kymelio-helm/paperless-ngx --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-paperless
```

## Required external services

Provide a reachable Redis instance through `externalRedis.url`:

```yaml
paperless:
  url: https://paperless.example.com
externalRedis:
  url: redis://redis:6379
```

## Storage

Documents, media, the consume directory and the SQLite database live under
`/usr/src/paperless/data` (`persistence.mountPath`) on a PersistentVolumeClaim.

## Secrets

`PAPERLESS_SECRET_KEY` is generated on first install and stored in the release
Secret. It is reused on upgrade so it stays stable. To manage it yourself, set
`auth.secretKey`, or create a Secret with the key `secret-key` and set
`auth.existingSecret`.

## Initial superuser

After the first install, create the admin account:

```sh
kubectl exec -it my-paperless-paperless-ngx-0 -- python3 manage.py createsuperuser
```

## Upgrading

Review the chart version change and your overridden values before upgrading.

```sh
helm upgrade my-paperless kymelio/paperless-ngx
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `ghcr.io/paperless-ngx/paperless-ngx` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| paperless.url | string | `http://localhost:8000` | Public URL Paperless-ngx is served from |
| auth.secretKey | string | `""` | Fixed secret key, generated when empty |
| auth.existingSecret | string | `""` | Use an existing Secret for the secret key |
| auth.secretKeys.secretKeyKey | string | `secret-key` | Secret key holding PAPERLESS_SECRET_KEY |
| externalRedis.url | string | `redis://redis:6379` | Redis connection string (PAPERLESS_REDIS) |
| persistence.enabled | bool | `true` | Enable a PersistentVolumeClaim |
| persistence.size | string | `8Gi` | Size of the PersistentVolumeClaim |
| persistence.mountPath | string | `/usr/src/paperless/data` | Data directory mount path |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `8000` | Service port |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| podDisruptionBudget.enabled | bool | `false` | Enable a PodDisruptionBudget |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| extraEnv | list | `[]` | Extra environment variables passed to the container |
