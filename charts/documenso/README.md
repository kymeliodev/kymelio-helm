# documenso

[Documenso](https://github.com/documenso/documenso) is an open source document
signing platform. It is deployed here as a stateless Deployment serving HTTP on
port 3000.

Documenso requires an external PostgreSQL database. This chart does not bundle
one. Provide a reachable instance and the application settings through
environment variables before installing.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-documenso kymelio/documenso
```

### OCI registry

```sh
helm install my-documenso oci://ghcr.io/kymeliodev/kymelio-helm/documenso --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-documenso
```

## Configuration

### Application settings

Documenso is configured through environment variables. Supply the database URL,
NextAuth secret, public URL and any SMTP or storage settings through `extraEnv`:

```yaml
extraEnv:
  - name: NEXTAUTH_URL
    value: https://sign.example.com
  - name: NEXTAUTH_SECRET
    value: change-me
  - name: NEXT_PRIVATE_DATABASE_URL
    value: postgres://documenso:password@postgresql:5432/documenso
  - name: NEXT_PRIVATE_SMTP_TRANSPORT
    value: smtp
  - name: NEXT_PRIVATE_SMTP_HOST
    value: smtp.example.com
```

For values that should come from a Secret, reference them with `extraEnvFrom`:

```yaml
extraEnvFrom:
  - secretRef:
      name: documenso-env
```

### TLS

Documenso serves plain HTTP on the application port and does not terminate TLS
itself. Front it with an ingress controller or reverse proxy that terminates
TLS, and set `NEXTAUTH_URL` to the public HTTPS address:

```yaml
ingress:
  enabled: true
  className: nginx
  hosts:
    - host: sign.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: sign-tls
      hosts:
        - sign.example.com
```

### Metrics

The Documenso image does not expose a built in Prometheus endpoint. There is no
official `/metrics` route, so this chart cannot scrape the application directly.

`metrics.enabled` is a marker that documents this requirement. To collect
metrics, run a sidecar or external exporter that publishes metrics on the HTTP
service port, then enable the ServiceMonitor (requires the Prometheus Operator
CRDs):

```yaml
metrics:
  enabled: true
  serviceMonitor:
    enabled: true
    interval: 30s
    labels:
      release: kube-prometheus-stack
```

The ServiceMonitor targets the service port. Without an exporter exposing metrics
on that port it will not collect Documenso specific series.

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-documenso kymelio/documenso --reuse-values
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `docker.io/documenso/documenso` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `3000` | Service port |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| podDisruptionBudget.enabled | bool | `false` | Enable a PodDisruptionBudget |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Marker for metrics support. Documenso has no built in Prometheus endpoint |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor scraping the HTTP port |
| extraEnv | list | `[]` | Extra environment variables passed to the container |
| extraEnvFrom | list | `[]` | Extra environment variables sourced from ConfigMaps or Secrets |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot | Pod security context |
| securityContext | object | drop ALL | Container security context |
