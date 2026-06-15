# argocd

Argo CD GitOps continuous delivery server for Kubernetes, deployed as a
stateless Deployment running the `argocd-server` component.

This chart deploys only the API and web server (`argocd-server`). A working
Argo CD installation also needs the following, which are installed separately:

- The Argo CD Custom Resource Definitions (Application, ApplicationSet,
  AppProject). This chart does not ship CRDs.
- The `argocd-repo-server` component that clones and renders source manifests.
- A Redis instance used by the server for caching.

The server starts with `--insecure` so it can sit behind a TLS terminating
ingress or proxy. The Service exposes an HTTP port and a gRPC port.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-argocd kymelio/argocd
```

### OCI registry

```sh
helm install my-argocd oci://ghcr.io/kymeliodev/kymelio-helm/argocd --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-argocd
```

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-argocd kymelio/argocd --reuse-values
```

## RBAC

The chart creates a ServiceAccount and a ClusterRole with a ClusterRoleBinding
so the server can read and reconcile Argo CD resources across namespaces. Set
`rbac.create=false` to manage these bindings yourself.

## Configuration

### Metrics

The `argocd-server` serves Prometheus metrics on a dedicated port at `/metrics`.
The endpoint is built in and needs no extra flag. Set `metrics.enabled=true` to
publish a `metrics` port (default `8083`) on the Deployment and Service, and
`metrics.serviceMonitor.enabled=true` to create a ServiceMonitor for the
Prometheus Operator that scrapes that port at `metrics.path`.

```yaml
metrics:
  enabled: true
  port: 8083
  path: /metrics
  serviceMonitor:
    enabled: true
    interval: 30s
    scrapeTimeout: 10s
    labels:
      release: kube-prometheus-stack
```

To expose gRPC request histograms, set `ARGOCD_ENABLE_GRPC_TIME_HISTOGRAM` on
the container through `extraEnv`.

### Server flags

Server behaviour is tuned with command line flags. The default flags are set in
`args`. Append additional flags with `extraArgs`, for example to raise the log
level:

```yaml
extraArgs:
  - --loglevel=debug
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `quay.io/argoproj/argocd` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| command | list | `["argocd-server"]` | Container entrypoint command |
| args | list | `["--insecure"]` | Arguments passed to the server |
| serviceAccount.create | bool | `true` | Create a ServiceAccount for the server |
| rbac.create | bool | `true` | Create the ClusterRole and ClusterRoleBinding |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.ports | list | http 8080, grpc 8083 | Service ports, the first entry is primary |
| ingress.enabled | bool | `false` | Enable an Ingress resource for the http port |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| podDisruptionBudget.enabled | bool | `false` | Enable a PodDisruptionBudget |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Publish a dedicated metrics port on the Deployment and Service |
| metrics.port | int | `8083` | Container and Service port for the metrics endpoint |
| metrics.path | string | `/metrics` | Path the metrics endpoint is served on |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| extraArgs | list | `[]` | Extra command line flags appended to the server |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 999 | Pod security context |
| securityContext | object | drop ALL | Container security context |
