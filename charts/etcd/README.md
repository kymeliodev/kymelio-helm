# etcd

A Helm chart for etcd, a distributed reliable key-value store. This chart deploys
a single node etcd as a StatefulSet with persistent storage.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-etcd kymelio/etcd
```

### OCI registry

```sh
helm install my-etcd oci://ghcr.io/kymeliodev/kymelio-helm/etcd --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-etcd
```

Uninstalling does not remove the PersistentVolumeClaim created by the StatefulSet.
Delete it manually if you no longer need the data:

```sh
kubectl delete pvc -l app.kubernetes.io/instance=my-etcd
```

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-etcd kymelio/etcd --reuse-values
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas. Single node only |
| image.repository | string | `quay.io/coreos/etcd` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| etcd.dataDir | string | `/etcd-data` | etcd data directory (ETCD_DATA_DIR) |
| etcd.listenClientUrls | string | `http://0.0.0.0:2379` | Client listen URLs (ETCD_LISTEN_CLIENT_URLS) |
| etcd.advertiseClientUrls | string | `http://0.0.0.0:2379` | Advertised client URLs (ETCD_ADVERTISE_CLIENT_URLS) |
| etcd.listenPeerUrls | string | `http://0.0.0.0:2380` | Peer listen URLs (ETCD_LISTEN_PEER_URLS) |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.ports.client.port | int | `2379` | Client API port |
| service.ports.peer.port | int | `2380` | Peer port |
| persistence.enabled | bool | `true` | Enable persistent storage |
| persistence.storageClass | string | `""` | StorageClass, empty uses the cluster default |
| persistence.accessModes | list | `[ReadWriteOnce]` | PersistentVolumeClaim access modes |
| persistence.size | string | `8Gi` | PersistentVolumeClaim size |
| persistence.mountPath | string | `/etcd-data` | Data mount path |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot, uid 1000 | Pod security context |
| securityContext | object | drop ALL | Container security context |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| podDisruptionBudget.enabled | bool | `false` | Enable a PodDisruptionBudget |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
