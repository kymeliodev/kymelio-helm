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
| metrics.enabled | bool | `false` | Enable the bundled /-/metrics endpoint on the HTTP port |
| metrics.monitoringAllowlist | list | `["0.0.0.0/0"]` | CIDR ranges permitted to read /-/metrics |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| metrics.serviceMonitor.path | string | `/-/metrics` | Path scraped by Prometheus |

## Configuration

### Metrics

GitLab serves its bundled Prometheus metrics at `/-/metrics` on the HTTP port
(`80`). Set `metrics.enabled=true` to append
`gitlab_rails['prometheus_metrics_enabled'] = true` and a
`monitoring_whitelist` to the Omnibus configuration so the endpoint is reachable
by scrapers. Enable the ServiceMonitor to have Prometheus scrape it:

```sh
helm install my-gitlab kymelio/gitlab \
  --set metrics.enabled=true \
  --set metrics.serviceMonitor.enabled=true
```

Restrict the allowlist to your Prometheus network rather than the open default:

```yaml
metrics:
  enabled: true
  monitoringAllowlist:
    - 10.0.0.0/8
    - 192.168.0.0/16
```

### Native configuration

Tune the instance through `omnibusConfig`, which is passed to the container as
`GITLAB_OMNIBUS_CONFIG`. Set `external_url` and any Omnibus setting, for example
to externalize the database and raise the worker count:

```yaml
omnibusConfig: |
  external_url 'https://gitlab.example.com'
  gitlab_rails['db_adapter'] = 'postgresql'
  gitlab_rails['db_host'] = 'postgres.db.svc'
  gitlab_rails['db_database'] = 'gitlabhq_production'
  puma['worker_processes'] = 4
```

### TLS

GitLab can terminate TLS itself through the bundled NGINX. Point `external_url`
at an `https://` address and let Omnibus request a Let's Encrypt certificate, or
disable the built in NGINX and terminate TLS at an Ingress instead:

```yaml
omnibusConfig: |
  external_url 'https://gitlab.example.com'
  letsencrypt['enable'] = true
  letsencrypt['contact_emails'] = ['admin@example.com']
```
