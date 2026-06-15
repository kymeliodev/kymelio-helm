# openbao

OpenBao secrets management and data protection server, deployed as a stateless
Deployment.

By default the chart starts OpenBao in development mode
(`server -dev -dev-listen-address=0.0.0.0:8200`) so it installs without storage
or manual unsealing. Development mode keeps all data in memory and is wiped on
restart. It is not suitable for production.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-openbao kymelio/openbao
```

### OCI registry

```sh
helm install my-openbao oci://ghcr.io/kymeliodev/kymelio-helm/openbao --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-openbao
```

## Upgrading

Review the chart version change and your overridden values before upgrading. The
generated development root token is preserved across upgrades when you keep
`auth.rootToken` empty and reuse the release Secret.

```sh
helm upgrade my-openbao kymelio/openbao
```

## Development mode

Development mode is enabled through `devMode.enabled`. The server starts
unsealed with an in-memory backend, and the root token is taken from
`BAO_DEV_ROOT_TOKEN_ID`, which is sourced from a Secret managed by this chart.

WARNING: development mode is intended for evaluation and testing only. Do not run
it in production. For a real deployment disable `devMode.enabled`, supply a
production server configuration with persistent storage, and manage unsealing
outside this chart.

## Configuration

### Metrics

OpenBao exposes telemetry at `/v1/sys/metrics?format=prometheus` on the API port
(8200). Set `metrics.enabled` to true and enable
`metrics.serviceMonitor.enabled` to scrape it with the Prometheus Operator. The
ServiceMonitor sets the path and the `format=prometheus` query parameter:

```yaml
metrics:
  enabled: true
  serviceMonitor:
    enabled: true
    interval: 30s
```

The endpoint only returns Prometheus output when a telemetry stanza is present.
In a production configuration add it to the server config, together with
unauthenticated scraping so Prometheus does not need a token:

```yaml
configuration: |
  telemetry {
    prometheus_retention_time = "24h"
    disable_hostname = true
  }
  listener "tcp" {
    address = "0.0.0.0:8200"
    tls_disable = true
    telemetry {
      unauthenticated_metrics_access = true
    }
  }
```

### TLS

OpenBao terminates TLS in its listener. Provide the certificate and key through
a mounted Secret and reference them in the listener stanza of the server
configuration:

```yaml
configuration: |
  listener "tcp" {
    address = "0.0.0.0:8200"
    tls_cert_file = "/config/tls/tls.crt"
    tls_key_file = "/config/tls/tls.key"
  }
extraVolumes:
  - name: tls
    secret:
      secretName: openbao-tls
extraVolumeMounts:
  - name: tls
    mountPath: /config/tls
    readOnly: true
```

### Native configuration

Disable development mode and supply a full HCL server configuration through
`configuration`, which is mounted into the container. Add the path as an
argument with `extraArgs`:

```yaml
devMode:
  enabled: false
configMountPath: /config
configFileName: config.hcl
extraArgs:
  - server
  - -config=/config/config.hcl
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `quay.io/openbao/openbao` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| devMode.enabled | bool | `true` | Run the server in development mode |
| devMode.args | list | dev server args | Arguments passed to the openbao binary |
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
| metrics.enabled | bool | `false` | Scrape the built-in /v1/sys/metrics endpoint |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| metrics.serviceMonitor.path | string | `/v1/sys/metrics` | Metrics path scraped by the ServiceMonitor |
| extraEnv | list | `[]` | Extra environment variables passed to the container |
