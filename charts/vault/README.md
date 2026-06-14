# vault

HashiCorp Vault secrets management and data protection server, deployed as a
stateless Deployment.

By default the chart starts Vault in development mode
(`server -dev -dev-listen-address=0.0.0.0:8200`) so it installs without storage
or manual unsealing. Development mode keeps all data in memory and is wiped on
restart. It is not suitable for production.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-vault kymelio/vault
```

### OCI registry

```sh
helm install my-vault oci://ghcr.io/kymeliodev/kymelio-helm/vault --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-vault
```

## Upgrading

Review the chart version change and your overridden values before upgrading. The
generated development root token is preserved across upgrades when you keep
`auth.rootToken` empty and reuse the release Secret.

```sh
helm upgrade my-vault kymelio/vault
```

## Development mode

Development mode is enabled through `devMode.enabled`. The server starts
unsealed with an in-memory backend, and the root token is taken from
`VAULT_DEV_ROOT_TOKEN_ID`, which is sourced from a Secret managed by this chart.

WARNING: development mode is intended for evaluation and testing only. Do not run
it in production. For a real deployment disable `devMode.enabled`, supply a
production server configuration with persistent storage, and manage unsealing
outside this chart.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `docker.io/hashicorp/vault` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| devMode.enabled | bool | `true` | Run the server in development mode |
| devMode.args | list | dev server args | Arguments passed to the vault binary |
| auth.rootToken | string | `""` | Development root token, generated when empty |
| auth.existingSecret | string | `""` | Use an existing Secret for the root token |
| auth.secretKeys.rootTokenKey | string | `root-token` | Secret key holding the root token |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `8200` | Service port |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 100 | Pod security context |
| securityContext | object | drop ALL | Container security context |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| podDisruptionBudget.enabled | bool | `false` | Enable a PodDisruptionBudget |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| extraEnv | list | `[]` | Extra environment variables passed to the container |
