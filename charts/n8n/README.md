# n8n

[n8n](https://n8n.io) is a workflow automation tool for connecting apps and
services. It is deployed here as a StatefulSet.

By default n8n runs standalone on a SQLite database stored on the persistent
volume, so no external database is required.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-n8n kymelio/n8n
```

### OCI registry

```sh
helm install my-n8n oci://ghcr.io/kymeliodev/kymelio-helm/n8n --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-n8n
```

## Public address

When exposing n8n behind a proxy, set the host, protocol and webhook URL so that
generated links and webhook callbacks are correct:

```yaml
n8n:
  host: n8n.example.com
  protocol: https
  webhookUrl: https://n8n.example.com/
```

## Storage

The SQLite database and all user data live under `/home/node/.n8n`
(`persistence.mountPath`) on a PersistentVolumeClaim.

## Encryption key

`N8N_ENCRYPTION_KEY` secures stored credentials. It is generated on first
install and stored in the release Secret, then reused on upgrade so it stays
stable. Changing this key makes previously stored credentials unreadable. To
manage it yourself, set `auth.encryptionKey`, or create a Secret with the key
`encryption-key` and set `auth.existingSecret`.

## Upgrading

Review the chart version change and your overridden values before upgrading.

```sh
helm upgrade my-n8n kymelio/n8n
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `docker.io/n8nio/n8n` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| n8n.host | string | `localhost` | Hostname n8n is reached on |
| n8n.protocol | string | `http` | Protocol used in generated URLs |
| n8n.webhookUrl | string | `http://localhost:5678/` | Public URL used for webhook callbacks |
| auth.encryptionKey | string | `""` | Fixed encryption key, generated when empty |
| auth.existingSecret | string | `""` | Use an existing Secret for the encryption key |
| auth.secretKeys.encryptionKeyKey | string | `encryption-key` | Secret key holding N8N_ENCRYPTION_KEY |
| persistence.enabled | bool | `true` | Enable a PersistentVolumeClaim |
| persistence.size | string | `8Gi` | Size of the PersistentVolumeClaim |
| persistence.mountPath | string | `/home/node/.n8n` | Data directory mount path |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `5678` | Service port |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| podDisruptionBudget.enabled | bool | `false` | Enable a PodDisruptionBudget |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| extraEnv | list | `[]` | Extra environment variables passed to the container |
