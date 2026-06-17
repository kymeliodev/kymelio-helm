# wordpress

Helm chart for [WordPress](https://wordpress.org/), the open source content
management system and website platform.

The chart deploys WordPress as a StatefulSet with a persistent volume mounted at
`/var/www/html` for the WordPress core, plugins, themes and uploads.

## Required external database

WordPress requires a MySQL or MariaDB database. This chart does not bundle one.
Deploy the kymelio `mariadb` or `mysql` chart, or point at any reachable
instance, and supply the connection details through `externalDatabase`. The
official WordPress image reads the connection from the `WORDPRESS_DB_HOST`,
`WORDPRESS_DB_USER`, `WORDPRESS_DB_NAME` and `WORDPRESS_DB_PASSWORD` environment
variables, which this chart sets from values and from a Secret. The database
password is sourced from a Secret managed by this chart, or from an existing
Secret named in `externalDatabase.existingSecret`. The database must already
exist and be owned by the configured user.

## Install

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-wordpress kymelio/wordpress \
  --set externalDatabase.host=mariadb.example \
  --set externalDatabase.user=wordpress \
  --set externalDatabase.database=wordpress
```

### OCI registry

```sh
helm install my-wordpress oci://ghcr.io/kymeliodev/kymelio-helm/wordpress --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-wordpress
```

## Rootless Apache

The official WordPress image runs Apache, which binds port 80 as root by
default. To keep the catalog security defaults (`runAsNonRoot`, all capabilities
dropped) this chart reconfigures Apache to listen on an unprivileged port. When
`apache.rootless.enabled` is true a ConfigMap with `ports.conf`, a virtual host
and `envvars` is mounted over the Apache configuration, the runtime directories
are redirected to a writable path, and the pod runs as the `www-data` user.

`service.port` and `apache.rootless.port` are both `8080` and must match. Set
both if you change the port:

```yaml
service:
  port: 8081
apache:
  rootless:
    port: 8081
```

Disable `apache.rootless.enabled` only when you provide your own Apache
configuration through `extraVolumes` and `extraVolumeMounts`.

## Configuration

### Application settings

The chart sets the database environment variables for you. Add any further
`WORDPRESS_*` settings through `extraEnv`. A common need is the authentication
keys and salts and inline `wp-config.php` additions:

```yaml
extraEnv:
  - name: WORDPRESS_CONFIG_EXTRA
    value: |
      define('WP_HOME', 'https://blog.example');
      define('WP_SITEURL', 'https://blog.example');
  - name: WORDPRESS_AUTH_KEY
    valueFrom:
      secretKeyRef:
        name: wordpress-keys
        key: auth-key
```

When serving WordPress behind a TLS terminating proxy, set `WP_HOME` and
`WP_SITEURL` to the external URL so generated links and admin redirects use the
correct scheme and host.

### TLS

WordPress serves plain HTTP and does not terminate TLS itself. Run it behind an
ingress controller, an OpenShift Route or a reverse proxy that terminates TLS,
and configure `ingress.tls` or `route.tls` accordingly.

### Metrics

The official WordPress image has no built in Prometheus endpoint. Install a
metrics plugin that exposes a `/metrics` route on the HTTP port, then enable
metrics here to create a ServiceMonitor that scrapes the HTTP port at
`metrics.path` (requires the Prometheus Operator CRDs):

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

Without a metrics plugin installed there is no endpoint to scrape and the
ServiceMonitor collects nothing.

## Upgrading

```sh
helm upgrade my-wordpress kymelio/wordpress --reuse-values
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `docker.io/library/wordpress` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| externalDatabase.host | string | `""` | External MySQL or MariaDB host |
| externalDatabase.port | int | `3306` | External database port |
| externalDatabase.user | string | `wordpress` | External database user |
| externalDatabase.database | string | `wordpress` | External database name |
| externalDatabase.password | string | `""` | Database password, generated when empty |
| externalDatabase.existingSecret | string | `""` | Existing Secret holding the database password |
| externalDatabase.secretKeys.passwordKey | string | `db-password` | Key in the Secret holding the password |
| externalDatabase.tablePrefix | string | `wp_` | WordPress table name prefix |
| apache.rootless.enabled | bool | `true` | Reconfigure Apache to listen unprivileged so the pod runs non-root |
| apache.rootless.port | int | `8080` | Unprivileged port Apache binds, keep equal to service.port |
| persistence.enabled | bool | `true` | Provision a PersistentVolumeClaim |
| persistence.size | string | `8Gi` | Volume size |
| persistence.mountPath | string | `/var/www/html` | Document root mount path |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `8080` | Service port, named http |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| route.enabled | bool | `false` | Enable an OpenShift Route |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| podDisruptionBudget.enabled | bool | `false` | Enable a PodDisruptionBudget |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.enabled | bool | `false` | Scrape the /metrics path served by a WordPress metrics plugin |
| metrics.path | string | `/metrics` | HTTP path scraped on the service port when metrics are enabled |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| extraEnv | list | `[]` | Extra environment variables passed to the container |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsUser 33 | Pod security context |
| securityContext | object | drop ALL | Container security context |
| openShift.enabled | bool | `false` | Omit explicit uids so the OpenShift SCC assigns them |
