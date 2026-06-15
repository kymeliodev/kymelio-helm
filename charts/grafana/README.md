# grafana

Grafana observability platform for building dashboards over metrics, logs and traces. This chart runs Grafana as a single replica StatefulSet with a persistent volume for its database and an admin password sourced from a Secret.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-grafana kymelio/grafana
```

### OCI registry

```sh
helm install my-grafana oci://ghcr.io/kymeliodev/kymelio-helm/grafana --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-grafana
```

## Upgrading

A generated admin password is read back from the existing Secret on upgrade so it stays stable. Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-grafana kymelio/grafana --reuse-values
```

## Admin credentials

When `auth.adminPassword` is empty a random password is generated on first install and reused on upgrade. Retrieve it with:

```sh
kubectl get secret my-grafana -o jsonpath="{.data.admin-password}" | base64 -d
```

## Configuration

Grafana settings are provided through environment variables (`extraEnv`) or a native `grafana.ini` mounted through `configuration`. The chart renders `configuration` into a ConfigMap and mounts it at `configMountPath`; a change to it updates a checksum annotation on the pod so it is rolled automatically.

```yaml
configuration: |
  [auth.anonymous]
  enabled = true
  org_role = Viewer
configFileName: grafana.ini
configMountPath: /etc/grafana
configSubPath: grafana.ini
```

### Monitoring

Grafana exposes its own Prometheus metrics at `/metrics` on the HTTP port (`service.port`, default 3000). Set `metrics.enabled` to advertise the endpoint and create a ServiceMonitor for the Prometheus Operator:

```yaml
metrics:
  enabled: true
  serviceMonitor:
    enabled: true
    path: /metrics
    interval: 30s
    labels:
      release: kube-prometheus-stack
```

### TLS

Grafana can serve HTTPS on its own HTTP server. Provide a Secret holding the certificate and key, then enable `tls`. The chart sets `GF_SERVER_PROTOCOL=https` and points Grafana at the mounted files:

```yaml
tls:
  enabled: true
  existingSecret: grafana-tls
  certFilename: tls.crt
  keyFilename: tls.key
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `docker.io/grafana/grafana` | Container image repository |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| auth.adminUser | string | `admin` | Value for GF_SECURITY_ADMIN_USER |
| auth.adminPassword | string | `""` | Admin password, generated when empty |
| auth.existingSecret | string | `""` | Use an existing Secret for the admin password |
| auth.secretKeys.passwordKey | string | `admin-password` | Secret key holding the admin password |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `3000` | HTTP service port |
| persistence.enabled | bool | `true` | Enable a persistent volume for /var/lib/grafana |
| persistence.size | string | `8Gi` | Persistent volume size |
| persistence.mountPath | string | `/var/lib/grafana` | Data directory mount path |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| metrics.enabled | bool | `false` | Advertise the built in /metrics endpoint on the HTTP port |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| metrics.serviceMonitor.path | string | `/metrics` | HTTP path scraped by the ServiceMonitor |
| tls.enabled | bool | `false` | Serve HTTPS from Grafana's own HTTP server |
| tls.existingSecret | string | `""` | Secret holding the certificate and key |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsUser 472 | Pod security context |
| securityContext | object | drop ALL | Container security context |
