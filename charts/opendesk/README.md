# opendesk

Helm chart that deploys a portal placeholder for
[openDesk](https://opendesk.eu/), the Sovereign Workplace.

## About openDesk

openDesk (Sovereign Workplace) is an umbrella suite, not a single application. A
complete deployment is composed of many independent services, including
collaborative document editing, groupware and mail, file sharing, video
conferencing, project management, chat and a central identity and portal layer.
Each component is operated and scaled separately.

This chart is deliberately scoped to a single representative web component: an
nginx based portal placeholder. It is intended as a landing page and as a
starting point for wiring the full suite. It does not deploy the complete
openDesk platform.

## Image

openDesk does not ship one consolidated container image for the whole suite.
This chart uses the official `docker.io/library/nginx` image to serve the portal
placeholder, which keeps the chart self contained and lint clean. Replace the
portal content through the `portal` values or front the real openDesk component
images per service.

## Behaviour

The nginx server is reconfigured to listen on the service port (8080) and runs
as the unprivileged nginx user (uid 101). The landing page is rendered from a
ConfigMap so it can be customised without rebuilding an image.

## Configuration

### Portal content

Customise the placeholder landing page through the `portal` values, or supply
your own nginx configuration and content through the `config`, `configuration`
and `extraVolumes` surfaces. Pass any nginx environment overrides through
`extraEnv`:

```yaml
portal:
  title: openDesk
  message: Welcome to the sovereign workplace.
```

### TLS

The nginx placeholder serves plain HTTP on port 8080 and does not terminate TLS
itself. Front it with an ingress controller or reverse proxy that terminates
TLS, and configure `ingress.tls` for the public host name.

### Metrics

openDesk is a suite of independent services (collaborative editing, groupware,
file sharing, video conferencing, project management, chat and identity), each
with its own monitoring. There is no single openDesk metrics endpoint, and the
nginx portal placeholder shipped by this chart does not expose Prometheus
metrics.

`metrics.enabled` is a marker that documents this. Enabling the ServiceMonitor
creates a monitor that scrapes the HTTP service port (requires the Prometheus
Operator CRDs). This becomes useful once you replace the placeholder with a real
component that exposes metrics on that port, or run a metrics exporter sidecar:

```yaml
metrics:
  enabled: true
  serviceMonitor:
    enabled: true
    interval: 30s
    labels:
      release: kube-prometheus-stack
```

To monitor the full suite, deploy and scrape each openDesk component through its
own chart and its own metrics endpoint.

## Install

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-opendesk kymelio/opendesk
```

## Uninstall

```sh
helm uninstall my-opendesk
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `docker.io/library/nginx` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| portal.title | string | `openDesk` | Title shown on the placeholder page |
| portal.message | string | placeholder text | Body text shown on the placeholder page |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `8080` | Service port, named http |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| podDisruptionBudget.enabled | bool | `false` | Enable a PodDisruptionBudget |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Marker for metrics support. The portal placeholder has no Prometheus endpoint |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor scraping the HTTP port |
| extraEnv | list | `[]` | Extra environment variables passed to the container |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsUser 101 | Pod security context |
| securityContext | object | drop ALL | Container security context |
