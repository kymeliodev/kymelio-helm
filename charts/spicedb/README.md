# spicedb

[SpiceDB](https://authzed.com/spicedb) is an open source authorization system
inspired by Google Zanzibar. This chart deploys it as a stateless Deployment.

By default SpiceDB runs in in-memory single node mode and keeps no persistent
storage. The gRPC preshared key used to authenticate API clients is stored in a
Secret, generated when left unset.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-spicedb kymelio/spicedb
```

### OCI registry

```sh
helm install my-spicedb oci://ghcr.io/kymeliodev/kymelio-helm/spicedb --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-spicedb
```

## Upgrading

Review the chart version change and your overridden values before upgrading. A
generated preshared key is preserved across upgrades when you keep
`auth.presharedKey` empty and reuse the release Secret.

```sh
helm upgrade my-spicedb kymelio/spicedb
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `ghcr.io/authzed/spicedb` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| auth.presharedKey | string | `""` | gRPC preshared key, generated when empty |
| auth.existingSecret | string | `""` | Use an existing Secret for the preshared key |
| auth.secretKeys.presharedKeyKey | string | `preshared-key` | Secret key holding the preshared key |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.ports.grpc.port | int | `50051` | gRPC API port |
| service.ports.http.port | int | `8080` | HTTP API port |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
