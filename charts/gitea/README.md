# gitea

A Helm chart for Gitea, a self hosted lightweight Git service with issue
tracking, pull requests, a wiki and a built in package registry.

## Ports

The StatefulSet exposes two ports:

- `http` on `3000` for the web UI and HTTP Git access.
- `ssh` on `22` for Git over SSH. Disable it with `service.ssh.enabled=false`.

## Storage and database

Gitea stores repositories, configuration and the embedded SQLite database under
`/data`. The default `extraEnv` sets `GITEA__database__DB_TYPE=sqlite3` and
`GITEA__server__ROOT_URL`. Set `GITEA__server__ROOT_URL` to the public address
so links and clone URLs resolve correctly, and override the
`GITEA__database__*` variables to use an external PostgreSQL or MySQL server.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-gitea kymelio/gitea
```

### OCI registry

```sh
helm install my-gitea oci://ghcr.io/kymeliodev/kymelio-helm/gitea --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-gitea
```

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-gitea kymelio/gitea --reuse-values
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `docker.io/gitea/gitea` | Container image repository |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `3000` | HTTP service port |
| service.portName | string | `http` | HTTP port name |
| service.ssh.enabled | bool | `true` | Expose the Git SSH port |
| service.ssh.port | int | `22` | SSH service port |
| service.ssh.portName | string | `ssh` | SSH port name |
| persistence.enabled | bool | `true` | Enable persistent storage for /data |
| persistence.size | string | `8Gi` | Persistent volume size |
| persistence.mountPath | string | `/data` | Mount path for Gitea data |
| extraEnv | list | sqlite3, root url | Extra environment variables |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot, uid 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |
