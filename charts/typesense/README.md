# typesense

Typesense typo-tolerant search engine, deployed as a single StatefulSet with
persistent storage.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-typesense kymelio/typesense
```

### OCI registry

```sh
helm install my-typesense oci://ghcr.io/kymeliodev/kymelio-helm/typesense --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-typesense
```

The PersistentVolumeClaim is retained after uninstall. Delete it manually to
discard the data.

## Upgrading

Review the chart version change and your overridden values before upgrading. A
generated API key is preserved across upgrades when you keep `auth.apiKey`
empty and reuse the release Secret.

```sh
helm upgrade my-typesense kymelio/typesense
```

## Configuration

### Metrics

Typesense does not expose a native Prometheus endpoint. It serves operational
metrics as JSON at `/metrics.json` (RAM, CPU, disk and network usage) and
`/stats.json` (per endpoint request rates and latencies) on the API port
(`8108`). Both require the `x-typesense-api-key` header.

Set `metrics.enabled=true` to add Prometheus scrape annotations to the pod and
point the ServiceMonitor at `metrics.path` on the API port:

```sh
helm install my-typesense kymelio/typesense \
  --set metrics.enabled=true \
  --set metrics.serviceMonitor.enabled=true
```

Because the native endpoint returns JSON rather than the Prometheus exposition
format, run a community exporter as a sidecar to convert it. Point the exporter
at `http://localhost:8108/metrics.json`, expose its Prometheus port, and set
`metrics.path` to the exporter path:

```yaml
metrics:
  enabled: true
  path: /metrics
  serviceMonitor:
    enabled: true
sidecars:
  - name: typesense-exporter
    image: ghcr.io/example/typesense-prometheus-exporter:latest
    env:
      - name: TYPESENSE_HOST
        value: "http://localhost:8108"
      - name: TYPESENSE_API_KEY
        valueFrom:
          secretKeyRef:
            name: my-typesense
            key: api-key
    ports:
      - name: metrics
        containerPort: 8080
```

### Native configuration

Typesense is configured with command line flags or the matching `TYPESENSE_`
environment variables. The chart already passes `--data-dir`, `--api-key` and
`--listen-port`. Add further flags with `extraArgs` and environment variables
with `extraEnv`:

```yaml
extraArgs:
  - --enable-cors
  - --max-memory-ratio
  - "0.8"
  - --num-collections-parallel-load
  - "4"
extraEnv:
  - name: TYPESENSE_LOG_LEVEL
    value: "INFO"
```

Use `extraEnvFrom` to source variables from ConfigMaps or Secrets you manage
outside the chart.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas |
| image.repository | string | `docker.io/typesense/typesense` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| auth.apiKey | string | `""` | Bootstrap API key, generated when empty |
| auth.existingSecret | string | `""` | Use an existing Secret for the API key |
| auth.secretKeys.apiKeyKey | string | `api-key` | Secret key holding the API key |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `8108` | Service port |
| persistence.enabled | bool | `true` | Enable a PersistentVolumeClaim |
| persistence.storageClass | string | `""` | StorageClass, empty uses the cluster default |
| persistence.size | string | `8Gi` | Size of the data volume |
| persistence.mountPath | string | `/data` | Data directory mount path |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Add Prometheus scrape annotations targeting `metrics.path` on the API port |
| metrics.path | string | `/metrics.json` | Metrics path scraped on the API port, override when using an exporter sidecar |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| extraArgs | list | `[]` | Extra command line flags appended to the Typesense entrypoint |
| extraEnv | list | `[]` | Extra environment variables passed to the container |
