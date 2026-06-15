# gitlab

A Helm chart for GitLab Community Edition, an all in one DevOps platform that
bundles Git hosting, issue tracking, CI and a container registry.

## All in one image

This chart deploys the GitLab Omnibus CE image
(`docker.io/gitlab/gitlab-ce`). The image packages PostgreSQL, Redis, Gitaly,
Puma, Sidekiq, NGINX and the other GitLab services into a single container
managed by the runit supervisor. No external database or cache is required for a
basic deployment, though large installations should externalize these services.

## Root requirement (security exception)

The Omnibus image must run as root (uid 0) so its internal supervisor can start
and manage the bundled services. This chart sets `runAsNonRoot: false` and
`runAsUser: 0` by design. Privilege escalation is disabled and all default
Linux capabilities are dropped to limit the blast radius.

## Ports

The StatefulSet exposes two ports:

- `http` on `80` for the web UI and HTTP Git access.
- `ssh` on `22` for Git over SSH. Disable it with `service.ssh.enabled=false`.

## Configuration and storage

GitLab persists all state under `/var/opt/gitlab`. Tune the instance through
`omnibusConfig`, which is passed to the container as `GITLAB_OMNIBUS_CONFIG`.
Set `external_url` to match the address users will reach. GitLab takes several
minutes to become healthy on first boot, so the probes use a generous
`initialDelaySeconds` of 120.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-gitlab kymelio/gitlab
```

### OCI registry

```sh
helm install my-gitlab oci://ghcr.io/kymeliodev/kymelio-helm/gitlab --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-gitlab
```

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-gitlab kymelio/gitlab --reuse-values
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `docker.io/gitlab/gitlab-ce` | Container image repository |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| omnibusConfig | string | `external_url ...` | Inline Omnibus config exported as GITLAB_OMNIBUS_CONFIG |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `80` | HTTP service port |
| service.portName | string | `http` | HTTP port name |
| service.ssh.enabled | bool | `true` | Expose the Git SSH port |
| service.ssh.port | int | `22` | SSH service port |
| service.ssh.portName | string | `ssh` | SSH port name |
| persistence.enabled | bool | `true` | Enable persistent storage |
| persistence.size | string | `20Gi` | Persistent volume size |
| persistence.mountPath | string | `/var/opt/gitlab` | Mount path for GitLab data |
| podSecurityContext | object | runAsUser 0 | Pod security context, root by exception |
| securityContext | object | runAsUser 0, drop ALL | Container security context, root by exception |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| resources | object | requests and limits | Container resource requests and limits |
