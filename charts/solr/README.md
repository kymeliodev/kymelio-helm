# solr

Apache Solr search platform, deployed as a StatefulSet with persistent storage
and a single HTTP endpoint on port 8983.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-solr kymelio/solr
```

### OCI registry

```sh
helm install my-solr oci://ghcr.io/kymeliodev/kymelio-helm/solr --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-solr
```

The PersistentVolumeClaim is retained after uninstall. Delete it manually to
discard the index data.

## Upgrading

Review the chart version change and your overridden values before upgrading.

```sh
helm upgrade my-solr kymelio/solr
```

## Configuration

### Metrics

Solr has no Prometheus endpoint on its HTTP port, but the image bundles the Solr
Prometheus exporter. Setting `metrics.enabled=true` runs `bin/solr-exporter` as a
sidecar built from the same image, scraping the local node and exposing metrics on
port 8989 at `/metrics`. The exporter port is added to the Service and the
ServiceMonitor switches to it when both flags are on.

```sh
helm install my-solr kymelio/solr \
  --set metrics.enabled=true \
  --set metrics.serviceMonitor.enabled=true
```

### Native configuration

Use `solrOpts` to append Java system properties to `SOLR_OPTS`, the native Solr
tuning mechanism, alongside the generic `configuration` surface.

```sh
helm install my-solr kymelio/solr \
  --set solrOpts="-Dsolr.autoSoftCommit.maxTime=3000"
```

### TLS

Solr enables HTTPS through `SOLR_SSL_*` settings backed by a Java keystore. Provide
a Secret with the PKCS12 keystore and truststore, and a Secret with their passwords.

```yaml
tls:
  enabled: true
  existingSecret: solr-ssl-keystores
  passwordSecret: solr-ssl-passwords
  keyStoreFilename: keystore.p12
  trustStoreFilename: truststore.p12
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas, ignored when autoscaling is enabled |
| image.repository | string | `docker.io/library/solr` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `8983` | Service port |
| service.portName | string | `http` | Service and container port name |
| persistence.enabled | bool | `true` | Enable a PersistentVolumeClaim |
| persistence.storageClass | string | `""` | StorageClass, empty uses the cluster default |
| persistence.size | string | `8Gi` | Size of the data volume |
| persistence.mountPath | string | `/var/solr` | Mount path for the Solr home directory |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsUser 8983 | Pod security context, runs as the solr user |
| securityContext | object | drop ALL | Container security context |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| podDisruptionBudget.enabled | bool | `false` | Enable a PodDisruptionBudget |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Run the bundled Solr Prometheus exporter as a sidecar |
| metrics.port | int | `8989` | Exporter listen and Service port |
| metrics.baseUrl | string | `http://localhost:8983/solr` | Solr base URL the exporter scrapes |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| solrOpts | string | `""` | Java system properties appended to SOLR_OPTS |
| tls.enabled | bool | `false` | Enable HTTPS through SOLR_SSL_* and a mounted keystore |
| tls.existingSecret | string | `""` | Secret holding the keystore and truststore |
| tls.passwordSecret | string | `""` | Secret holding the keystore and truststore passwords |
| tls.keyStoreFilename | string | `keystore.p12` | Keystore file name in the Secret |
| tls.trustStoreFilename | string | `truststore.p12` | Truststore file name in the Secret |
| extraEnv | list | `[]` | Extra environment variables for the container |
| tests.image | string | `busybox:1.36` | Image used by the helm test connection check |
