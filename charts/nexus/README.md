# nexus

A Helm chart for Sonatype Nexus Repository 3, a universal artifact manager that
hosts and proxies Maven, npm, Docker, PyPI, NuGet and many other package
formats.

## Storage

Nexus persists all repository data, configuration and the embedded database
under `/nexus-data` through the StatefulSet volume claim template.

## Security and user

The Sonatype Nexus image runs as the `nexus` user with uid 200. The chart sets
`runAsUser: 200` and `fsGroup: 200` so the data directory is writable. Nexus is
memory hungry; size `resources` to the documented JVM heap before going to
production.

## Startup time

Nexus takes a while to initialize on first boot, so the probes use a generous
`initialDelaySeconds` of 120 against `/service/rest/v1/status`.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-nexus kymelio/nexus
```

### OCI registry

```sh
helm install my-nexus oci://ghcr.io/kymeliodev/kymelio-helm/nexus --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-nexus
```

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-nexus kymelio/nexus --reuse-values
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `docker.io/sonatype/nexus3` | Container image repository |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `8081` | HTTP service port |
| service.portName | string | `http` | HTTP port name |
| persistence.enabled | bool | `true` | Enable persistent storage |
| persistence.size | string | `8Gi` | Persistent volume size |
| persistence.mountPath | string | `/nexus-data` | Mount path for Nexus data |
| podSecurityContext | object | runAsNonRoot, uid 200 | Pod security context |
| securityContext | object | drop ALL | Container security context |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| resources | object | requests and limits | Container resource requests and limits |
| metrics.enabled | bool | `false` | Scrape the native Nexus Prometheus endpoint |
| metrics.path | string | `/service/metrics/prometheus` | Path Nexus serves Prometheus metrics on |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| metrics.serviceMonitor.basicAuthSecret | string | `""` | Secret holding scrape credentials |

## Configuration

### Metrics

Nexus serves Prometheus metrics natively on the HTTP port (`8081`) at
`/service/metrics/prometheus`. The endpoint requires authentication through the
`nx-metrics-all` privilege, so the ServiceMonitor references a Secret holding
the scrape credentials. Create the Secret and enable the ServiceMonitor:

```sh
kubectl create secret generic nexus-metrics \
  --from-literal=username=metrics \
  --from-literal=password=changeme

helm install my-nexus kymelio/nexus \
  --set metrics.enabled=true \
  --set metrics.serviceMonitor.enabled=true \
  --set metrics.serviceMonitor.basicAuthSecret=nexus-metrics
```

The Secret keys default to `username` and `password`; override them with
`metrics.serviceMonitor.usernameKey` and `metrics.serviceMonitor.passwordKey`.

### Native configuration

Pass JVM and Nexus settings through `extraEnv`. For example, set the heap and
direct memory and supply an admin password file on first boot:

```yaml
extraEnv:
  - name: INSTALL4J_ADD_VM_PARAMS
    value: "-Xms2703m -Xmx2703m -XX:MaxDirectMemorySize=2703m"
  - name: NEXUS_SECURITY_RANDOMPASSWORD
    value: "false"
```

The generic `configuration` surface remains available to mount an inline
`nexus.properties` through a ConfigMap.

### TLS

Nexus can terminate TLS through its embedded Jetty server, but the common
pattern is to run it behind an Ingress or reverse proxy that terminates TLS.
Enable `ingress` and attach a certificate Secret there:

```yaml
ingress:
  enabled: true
  className: nginx
  hosts:
    - host: nexus.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: nexus-tls
      hosts:
        - nexus.example.com
```
