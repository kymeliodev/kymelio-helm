# neo4j

Neo4j graph database, deployed as a single node StatefulSet with persistent
storage. The `NEO4J_AUTH` credential is stored in a Secret as `neo4j/<password>`.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-neo4j kymelio/neo4j
```

### OCI registry

```sh
helm install my-neo4j oci://ghcr.io/kymeliodev/kymelio-helm/neo4j --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-neo4j
```

The PersistentVolumeClaim is retained after uninstall. Delete it manually to
discard the data.

## Upgrading

Review the chart version change and your overridden values before upgrading. A
generated password is preserved across upgrades when you keep `auth.password`
empty and reuse the release Secret.

```sh
helm upgrade my-neo4j kymelio/neo4j
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas, fixed at one |
| image.repository | string | `docker.io/library/neo4j` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| auth.username | string | `neo4j` | User created on first start |
| auth.password | string | `""` | Password, generated when empty |
| auth.existingSecret | string | `""` | Use an existing Secret for credentials |
| auth.secretKeys.authKey | string | `neo4j-auth` | Secret key holding `neo4j/<password>` |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.ports.bolt.port | int | `7687` | Bolt protocol port |
| service.ports.http.port | int | `7474` | HTTP browser port |
| persistence.enabled | bool | `true` | Enable a PersistentVolumeClaim |
| persistence.storageClass | string | `""` | StorageClass, empty uses the cluster default |
| persistence.size | string | `8Gi` | Size of the data volume |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot 7474 | Pod security context |
| securityContext | object | drop ALL | Container security context |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
