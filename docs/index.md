# Kymelio Helm Charts

A curated catalog of production grade Helm charts for popular cloud native
applications. Each chart is a clean, standalone implementation.

## Add the repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
```

Charts are also available as OCI artifacts under
`oci://ghcr.io/kymeliodev/kymelio-helm`.

## Catalog

Charts are organized into the following categories. Entries are filled in as the
catalog grows.

### Databases and stores

PostgreSQL, MariaDB, MySQL, MongoDB, Redis, Valkey, CockroachDB, Cassandra,
CouchDB, Couchbase, SpiceDB, Neo4j, InfluxDB, TimescaleDB, ClickHouse, QuestDB,
ScyllaDB, etcd, Dragonfly, SurrealDB.

### Search

Elasticsearch, OpenSearch, Meilisearch, Quickwit, Typesense, Solr, Qdrant,
Weaviate, Milvus.

### Message brokers

RabbitMQ, ActiveMQ, Mosquitto, HiveMQ, VerneMQ, NATS, EMQX, Pulsar, Redpanda.

### Identity, secrets and security

Keycloak, OpenBao, Vault, Authentik, Authelia, Zitadel, Airlock Microgateway,
cert-manager, Trivy, Falco, Kyverno, OPA Gatekeeper, external-secrets,
sealed-secrets.

### Registry and code hosting

Harbor, Forgejo, Codey, GitLab, Gitea, Zot, Nexus.

### Platform, GitOps and IaC

ArgoCD, Flux, Crossplane, Backstage, Kubernetes Namespace, Tekton,
Argo Workflows, Argo Rollouts, Knative, KEDA, Kamaji, Cluster API Operator.

### Observability

Grafana, Prometheus, Loki, Tempo, Mimir, Thanos, VictoriaMetrics, Jaeger,
OpenTelemetry Collector, Vector, Uptime Kuma.

### Storage and backup

MinIO, Longhorn, Velero, Rook Ceph, SeaweedFS.

### SaaS and collaboration

Nextcloud, OpenCloud, OpenTalk, openDesk, Odoo, Apache Superset, Mattermost,
Outline, Vikunja, Paperless-ngx, n8n, Plausible, Documenso, WordPress.
