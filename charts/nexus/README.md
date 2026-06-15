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
