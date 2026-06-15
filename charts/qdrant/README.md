# qdrant

A Helm chart for Qdrant, a vector similarity search engine and database.

The chart deploys a single Qdrant instance as a StatefulSet exposing the HTTP
REST API on port 6333 and the gRPC API on port 6334. API key authentication is
optional and disabled by default.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-qdrant kymelio/qdrant
```

### OCI registry

```sh
helm install my-qdrant oci://ghcr.io/kymeliodev/kymelio-helm/qdrant --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-qdrant
```

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-qdrant kymelio/qdrant --reuse-values
```

## Authentication

API key authentication is disabled by default. Enable it with
`auth.enabled=true`. When enabled and `auth.apiKey` is empty, a random key is
generated and stored in a managed Secret. The generated key is reused across
upgrades. To supply your own Secret, set `auth.existingSecret` to its name and
`auth.secretKeys.apiKeyKey` to the key holding the API key.

```sh
helm install my-qdrant kymelio/qdrant --set auth.enabled=true
```

Retrieve the generated key with:

```sh
kubectl get secret my-qdrant -o jsonpath="{.data.api-key}" | base64 -d
```

Send the key on each request with the `api-key` header.

## Configuration

### Metrics

Qdrant serves Prometheus metrics natively at `/metrics` on the HTTP port
(`6333`). No exporter sidecar is required. Set `metrics.enabled=true` to add
Prometheus scrape annotations to the pod, and `metrics.serviceMonitor.enabled=true`
to create a ServiceMonitor for the Prometheus Operator.

```sh
helm install my-qdrant kymelio/qdrant \
  --set metrics.enabled=true \
  --set metrics.serviceMonitor.enabled=true
```

The scrape path is controlled by `metrics.path` (default `/metrics`).

### Native configuration

Qdrant reads configuration files from `/qdrant/config`. Provide a native
`config.yaml` through the `configuration` value. It is rendered into a ConfigMap
and mounted into the configuration directory, overriding the image defaults.

```yaml
configuration: |
  service:
    max_request_size_mb: 64
  storage:
    optimizers:
      default_segment_number: 4
  log_level: INFO
```

Use the generic `config` map for free form ConfigMap entries, or
`existingConfigMap` to mount a ConfigMap you manage outside the chart.

### TLS

Qdrant terminates TLS for the REST and gRPC APIs when `service.enable_tls` is
set. Enable it with `tls.enabled=true` and reference a Secret holding the
certificate and key. The chart sets the `QDRANT__SERVICE__ENABLE_TLS`,
`QDRANT__TLS__CERT` and `QDRANT__TLS__KEY` environment variables and mounts the
Secret at `tls.mountPath` (default `/qdrant/tls`).

```sh
kubectl create secret generic qdrant-tls \
  --from-file=tls.crt=server.crt \
  --from-file=tls.key=server.key

helm install my-qdrant kymelio/qdrant \
  --set tls.enabled=true \
  --set tls.existingSecret=qdrant-tls
```

Set `tls.caFilename` to also pass a CA certificate through
`QDRANT__TLS__CA_CERT`.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `docker.io/qdrant/qdrant` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| auth.enabled | bool | `false` | Require an API key to access the service |
| auth.apiKey | string | `""` | API key used when auth is enabled, a random key is generated when empty |
| auth.existingSecret | string | `""` | Use an existing Secret instead of managing the key in this chart |
| auth.secretKeys.apiKeyKey | string | `api-key` | Key inside the Secret that holds the API key |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.http.port | int | `6333` | HTTP REST API port |
| service.http.portName | string | `http` | HTTP port name |
| service.grpc.port | int | `6334` | gRPC API port |
| service.grpc.portName | string | `grpc` | gRPC port name |
| ingress.enabled | bool | `false` | Enable an Ingress resource for the HTTP API |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| podDisruptionBudget.enabled | bool | `false` | Enable a PodDisruptionBudget |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Add Prometheus scrape annotations for the built in `/metrics` endpoint |
| metrics.path | string | `/metrics` | Path of the built in Prometheus endpoint on the HTTP port |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| tls.enabled | bool | `false` | Enable server side TLS for the REST and gRPC APIs |
| tls.existingSecret | string | `""` | Secret holding the certificate, key and optional CA certificate |
| tls.certFilename | string | `tls.crt` | Certificate file name inside the Secret |
| tls.keyFilename | string | `tls.key` | Private key file name inside the Secret |
| tls.caFilename | string | `""` | Optional CA certificate file name inside the Secret |
| tls.mountPath | string | `/qdrant/tls` | Mount path for the TLS material |
| configuration | string | `""` | Native Qdrant `config.yaml` rendered into a ConfigMap and mounted at `/qdrant/config` |
| persistence.enabled | bool | `true` | Provision a PersistentVolumeClaim for storage |
| persistence.size | string | `8Gi` | Size of the persistent volume |
| persistence.mountPath | string | `/qdrant/storage` | Storage mount path inside the container |
| extraEnv | list | `[]` | Extra environment variables passed to the container |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot, UID 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |
