# odoo

Helm chart for [Odoo](https://www.odoo.com/), the open source ERP and CRM
business management suite.

The chart deploys Odoo as a StatefulSet with a persistent volume mounted at
`/var/lib/odoo` for filestore and session data.

## Required external database

Odoo requires PostgreSQL. This chart does not bundle a database. Provide a
reachable PostgreSQL instance and supply the connection details through
`externalDatabase`. The official Odoo image reads the connection from the `HOST`,
`PORT`, `USER` and `PASSWORD` environment variables, which this chart sets from
values and from a Secret. The database password is sourced from a Secret managed
by this chart, or from an existing Secret named in
`externalDatabase.existingSecret`. The configured user must have permission to
create databases.

## Install

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-odoo kymelio/odoo \
  --set externalDatabase.host=postgres.example \
  --set externalDatabase.user=odoo
```

## Uninstall

```sh
helm uninstall my-odoo
```

## Configuration

### Application settings

The official Odoo image reads the database connection from the `HOST`, `PORT`,
`USER` and `PASSWORD` environment variables, which the chart sets for you. Add
any further runtime variables through `extraEnv`, and pass command line flags to
the entrypoint through `extraArgs`:

```yaml
extraEnv:
  - name: ODOO_RC
    value: /etc/odoo/odoo.conf
extraArgs:
  - --workers=4
  - --limit-time-cpu=600
```

To supply a native `odoo.conf`, render one with `configuration` and mount it
where Odoo expects it:

```yaml
configuration: |
  [options]
  workers = 4
  proxy_mode = True
configMountPath: /etc/odoo
configFileName: odoo.conf
configSubPath: odoo.conf
```

### TLS

Odoo serves plain HTTP on port 8069 and does not terminate TLS itself. Run it
behind an ingress controller or reverse proxy that terminates TLS, and set
`proxy_mode = True` in the Odoo configuration so it trusts the forwarded
headers. Configure `ingress.tls` accordingly.

### Metrics

The official Odoo image has no built in Prometheus endpoint. The community OCA
module
[`monitoring_prometheus`](https://github.com/camptocamp/odoo-cloud-platform/tree/16.0/monitoring_prometheus)
adds a `/metrics` route served on the same HTTP port (8069). Install that module
in your Odoo addons and activate it, then enable metrics here to create a
ServiceMonitor that scrapes the HTTP port at `metrics.path` (requires the
Prometheus Operator CRDs):

```yaml
metrics:
  enabled: true
  path: /metrics
  serviceMonitor:
    enabled: true
    interval: 30s
    labels:
      release: kube-prometheus-stack
```

Without the `monitoring_prometheus` module installed there is no endpoint to
scrape and the ServiceMonitor collects nothing.

## Upgrading

```sh
helm upgrade my-odoo kymelio/odoo --reuse-values
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `docker.io/library/odoo` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| externalDatabase.host | string | `""` | External PostgreSQL host (HOST) |
| externalDatabase.port | int | `5432` | External PostgreSQL port (PORT) |
| externalDatabase.user | string | `odoo` | External PostgreSQL user (USER) |
| externalDatabase.password | string | `""` | Database password, generated when empty (PASSWORD) |
| externalDatabase.existingSecret | string | `""` | Existing Secret holding the database password |
| externalDatabase.secretKeys.passwordKey | string | `db-password` | Key in the Secret holding the password |
| persistence.enabled | bool | `true` | Provision a PersistentVolumeClaim |
| persistence.size | string | `8Gi` | Volume size |
| persistence.mountPath | string | `/var/lib/odoo` | Data mount path |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `8069` | Service port, named http |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| podDisruptionBudget.enabled | bool | `false` | Enable a PodDisruptionBudget |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Scrape the /metrics path served by the OCA monitoring_prometheus module |
| metrics.path | string | `/metrics` | HTTP path scraped on the service port when metrics are enabled |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| extraEnv | list | `[]` | Extra environment variables passed to the container |
| extraArgs | list | `[]` | Extra command line arguments appended to the entrypoint |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsUser 101 | Pod security context |
| securityContext | object | drop ALL | Container security context |
