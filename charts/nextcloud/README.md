# nextcloud

Helm chart for [Nextcloud](https://nextcloud.com/), a self hosted content
collaboration platform for file storage, sharing and synchronization.

The chart deploys Nextcloud as a StatefulSet with a persistent volume mounted at
`/var/www/html`. The administrator account is created on first start, with the
user name taken from values and the password sourced from a Secret.

## Database

Nextcloud runs standalone on SQLite by default, which is suitable for evaluation
and small instances. For production use an external MySQL, MariaDB or PostgreSQL
database. This chart does not bundle a database. Set `externalDatabase.type` to
`mysql` or `pgsql` and provide the connection details. The database password is
read from a Secret named in `externalDatabase.existingSecret`.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-nextcloud kymelio/nextcloud
```

### OCI registry

```sh
helm install my-nextcloud oci://ghcr.io/kymeliodev/kymelio-helm/nextcloud --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-nextcloud
```

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-nextcloud kymelio/nextcloud --reuse-values
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `docker.io/library/nextcloud` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| auth.adminUser | string | `admin` | Initial administrator user name (NEXTCLOUD_ADMIN_USER) |
| auth.adminPassword | string | `""` | Administrator password, generated when empty (NEXTCLOUD_ADMIN_PASSWORD) |
| auth.existingSecret | string | `""` | Existing Secret holding the admin password |
| auth.secretKeys.passwordKey | string | `admin-password` | Key in the Secret holding the admin password |
| externalDatabase.type | string | `sqlite` | Database backend: sqlite, mysql or pgsql |
| externalDatabase.host | string | `""` | External database host |
| externalDatabase.port | string | `""` | External database port |
| externalDatabase.database | string | `nextcloud` | External database name |
| externalDatabase.user | string | `nextcloud` | External database user |
| externalDatabase.existingSecret | string | `""` | Secret holding the database password |
| externalDatabase.existingSecretPasswordKey | string | `db-password` | Key in the database Secret |
| persistence.enabled | bool | `true` | Provision a PersistentVolumeClaim |
| persistence.size | string | `8Gi` | Volume size |
| persistence.mountPath | string | `/var/www/html` | Data mount path |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `80` | Service port, named http |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| podDisruptionBudget.enabled | bool | `false` | Enable a PodDisruptionBudget |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Run a nextcloud-exporter sidecar and expose its Prometheus port |
| metrics.image.repository | string | `ghcr.io/xperimental/nextcloud-exporter` | Exporter image repository |
| metrics.image.tag | string | `0.6.2` | Exporter image tag |
| metrics.port | int | `9205` | Exporter Prometheus scrape port |
| metrics.serverURL | string | `http://127.0.0.1:80` | URL the exporter uses to reach Nextcloud |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| metrics.serviceMonitor.interval | string | `30s` | Scrape interval |
| metrics.serviceMonitor.scrapeTimeout | string | `10s` | Scrape timeout |
| metrics.serviceMonitor.labels | object | `{}` | Extra labels for the ServiceMonitor |
| extraEnv | list | `[]` | Extra environment variables passed to the container |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsUser 33 | Pod security context |
| securityContext | object | drop ALL | Container security context |

## Configuration

Nextcloud is configured through `NEXTCLOUD_*`, `POSTGRES_*` and `MYSQL_*`
environment variables. The chart wires the admin account and the database
connection; use `extraEnv` for additional settings such as trusted domains and
the overwrite protocol behind a reverse proxy.

```yaml
extraEnv:
  - name: NEXTCLOUD_TRUSTED_DOMAINS
    value: cloud.example.com
  - name: OVERWRITEPROTOCOL
    value: https
  - name: OVERWRITECLIURL
    value: https://cloud.example.com
  - name: PHP_MEMORY_LIMIT
    value: 1024M
```

### Metrics

Nextcloud does not expose a native Prometheus endpoint. Setting `metrics.enabled`
runs the community
[nextcloud-exporter](https://github.com/xperimental/nextcloud-exporter) as a
sidecar. It queries the Nextcloud serverinfo API using the admin credentials
managed by this chart and serves Prometheus metrics on port `9205` at
`/metrics`. The Service exposes that port and the ServiceMonitor scrapes it.

```yaml
metrics:
  enabled: true
  serviceMonitor:
    enabled: true
```

The serverinfo app must be enabled in Nextcloud (it ships enabled by default).
Scraping with the admin user works out of the box; for least privilege, create a
dedicated monitoring user or a serverinfo token and override `metrics.serverURL`
and the exporter credentials. The ServiceMonitor requires the Prometheus
Operator CRDs.

### Ingress and TLS

Nextcloud serves plain HTTP on port `80` and expects TLS to be terminated by an
ingress controller or reverse proxy. Enable `ingress` with `ingress.tls` and set
`OVERWRITEPROTOCOL=https` through `extraEnv` rather than configuring TLS on the
application.
