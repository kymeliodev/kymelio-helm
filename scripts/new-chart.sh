#!/usr/bin/env bash
#
# Scaffold a conformant Helm chart skeleton.
#
# Usage:
#   scripts/new-chart.sh --name NAME --app-version VERSION \
#     --image-repository REPO [--workload deployment|statefulset] [--port PORT]
#
set -euo pipefail

NAME=""
APP_VERSION=""
IMAGE_REPOSITORY=""
WORKLOAD="deployment"
PORT="8080"

usage() {
  grep '^#' "$0" | sed 's/^#//'
  exit 1
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --name) NAME="$2"; shift 2 ;;
    --app-version) APP_VERSION="$2"; shift 2 ;;
    --image-repository) IMAGE_REPOSITORY="$2"; shift 2 ;;
    --workload) WORKLOAD="$2"; shift 2 ;;
    --port) PORT="$2"; shift 2 ;;
    -h|--help) usage ;;
    *) echo "Unknown argument: $1" >&2; usage ;;
  esac
done

if [ -z "$NAME" ] || [ -z "$APP_VERSION" ] || [ -z "$IMAGE_REPOSITORY" ]; then
  echo "Error: --name, --app-version and --image-repository are required." >&2
  usage
fi

if [ "$WORKLOAD" != "deployment" ] && [ "$WORKLOAD" != "statefulset" ]; then
  echo "Error: --workload must be deployment or statefulset." >&2
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CHART_DIR="${REPO_ROOT}/charts/${NAME}"

if [ -d "$CHART_DIR" ]; then
  echo "Error: chart already exists at ${CHART_DIR}." >&2
  exit 1
fi

MAINTAINER_NAME="$(git config user.name 2>/dev/null || true)"
MAINTAINER_EMAIL="$(git config user.email 2>/dev/null || true)"
MAINTAINER_NAME="${MAINTAINER_NAME:-Kymelio}"
MAINTAINER_EMAIL="${MAINTAINER_EMAIL:-simon.meier@kymelio.com}"

mkdir -p "${CHART_DIR}/templates/tests"

cat > "${CHART_DIR}/Chart.yaml" <<EOF
apiVersion: v2
name: ${NAME}
description: A Helm chart for ${NAME}
type: application
version: 0.1.0
appVersion: "${APP_VERSION}"
home: https://github.com/kymeliodev/kymelio-helm
sources:
  - https://github.com/kymeliodev/kymelio-helm
keywords:
  - ${NAME}
maintainers:
  - name: ${MAINTAINER_NAME}
    email: ${MAINTAINER_EMAIL}
EOF

cat > "${CHART_DIR}/values.yaml" <<EOF
# Number of replicas. Ignored when autoscaling is enabled.
replicaCount: 1

# Container image configuration.
image:
  repository: ${IMAGE_REPOSITORY}
  pullPolicy: IfNotPresent
  # Defaults to the chart appVersion when empty. Never use a floating tag.
  tag: ""

# Image pull secrets for private registries.
imagePullSecrets: []

# Override the chart name used in resource names.
nameOverride: ""
# Override the fully qualified resource name.
fullnameOverride: ""

# Service account used by the workload.
serviceAccount:
  create: true
  automount: true
  annotations: {}
  name: ""

# Annotations added to the pod.
podAnnotations: {}

# Pod level security context.
podSecurityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 1000
  seccompProfile:
    type: RuntimeDefault

# Container level security context.
securityContext:
  allowPrivilegeEscalation: false
  # Set to true for images that tolerate an immutable root filesystem.
  readOnlyRootFilesystem: false
  runAsNonRoot: true
  capabilities:
    drop:
      - ALL

# Service exposing the workload.
service:
  type: ClusterIP
  port: ${PORT}
  portName: ${NAME}

# Ingress configuration. Disabled by default.
ingress:
  enabled: false
  className: ""
  annotations: {}
  hosts:
    - host: chart-example.local
      paths:
        - path: /
          pathType: Prefix
  tls: []

# Resource requests and limits.
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi

# Horizontal pod autoscaler. Disabled by default.
autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 5
  targetCPUUtilizationPercentage: 80

# Pod disruption budget. Disabled by default.
podDisruptionBudget:
  enabled: false
  minAvailable: 1

# Network policy. Disabled by default.
networkPolicy:
  enabled: false
  ingress: []

# Prometheus integration. Disabled by default.
metrics:
  serviceMonitor:
    enabled: false
    interval: 30s
    scrapeTimeout: 10s
    labels: {}

# Extra command line arguments appended to the container entrypoint.
extraArgs: []

# Extra environment variables passed to the container.
extraEnv: []

# Extra environment variables sourced from ConfigMaps or Secrets (envFrom).
extraEnvFrom: []

# Inline application configuration. When set it is rendered into a ConfigMap and
# mounted at configMountPath. Use this for native config files like an app.conf.
configuration: ""
# File name for the rendered configuration inside the mount path.
configFileName: app.conf
# Mount path for the configuration.
configMountPath: /config
# Mount the configuration as a single file using subPath. Leave empty to mount
# the whole ConfigMap as a directory.
configSubPath: ""
# Use an existing ConfigMap for the configuration instead of rendering one.
existingConfigMap: ""

# Free form configuration rendered into a ConfigMap when not empty.
config: {}

# Additional volumes and mounts for the workload.
extraVolumes: []
extraVolumeMounts: []

# Additional init containers and sidecar containers.
initContainers: []
sidecars: []

# Extra labels added to the pod template.
podLabels: {}
# Pod priority class.
priorityClassName: ""

# Node scheduling controls.
nodeSelector: {}
tolerations: []
affinity: {}

# Image used by the helm test connection check.
tests:
  image: busybox:1.36

# OpenShift Route exposing the service externally. Disabled by default.
route:
  enabled: false
  host: ""
  # Target service port name or number. Leave empty for single port services.
  port: ""
  annotations: {}
  # TLS configuration, for example { termination: edge }.
  tls: {}
  wildcardPolicy: None

# OpenShift compatibility. When enabled, the explicit runAsUser, runAsGroup and
# fsGroup are omitted so the restricted SCC assigns them from the namespace range.
openShift:
  enabled: false
EOF

if [ "$WORKLOAD" = "statefulset" ]; then
  cat >> "${CHART_DIR}/values.yaml" <<EOF

# Persistent storage for the StatefulSet.
persistence:
  enabled: true
  # Leave empty to use the cluster default StorageClass.
  storageClass: ""
  accessModes:
    - ReadWriteOnce
  size: 8Gi
  mountPath: /data
EOF
fi

cat > "${CHART_DIR}/values.schema.json" <<'JSON'
{
  "$schema": "https://json-schema.org/draft-07/schema#",
  "type": "object",
  "properties": {
    "replicaCount": {
      "type": "integer",
      "minimum": 0
    },
    "image": {
      "type": "object",
      "required": ["repository"],
      "properties": {
        "repository": { "type": "string", "minLength": 1 },
        "pullPolicy": {
          "type": "string",
          "enum": ["Always", "IfNotPresent", "Never"]
        },
        "tag": { "type": "string" }
      }
    },
    "service": {
      "type": "object",
      "required": ["type", "port"],
      "properties": {
        "type": {
          "type": "string",
          "enum": ["ClusterIP", "NodePort", "LoadBalancer"]
        },
        "port": { "type": "integer", "minimum": 1, "maximum": 65535 }
      }
    },
    "resources": { "type": "object" },
    "autoscaling": {
      "type": "object",
      "properties": {
        "enabled": { "type": "boolean" }
      }
    }
  }
}
JSON

cat > "${CHART_DIR}/templates/_helpers.tpl" <<'TPL'
{{/*
Expand the name of the chart.
*/}}
{{- define "__NAME__.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "__NAME__.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Chart name and version label value.
*/}}
{{- define "__NAME__.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "__NAME__.labels" -}}
helm.sh/chart: {{ include "__NAME__.chart" . }}
{{ include "__NAME__.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: {{ include "__NAME__.name" . }}
{{- end }}

{{/*
Selector labels.
*/}}
{{- define "__NAME__.selectorLabels" -}}
app.kubernetes.io/name: {{ include "__NAME__.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Service account name.
*/}}
{{- define "__NAME__.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "__NAME__.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
TPL

# Shared pod spec body fragment used by both workload kinds.
read -r -d '' POD_SPEC <<'TPL' || true
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      serviceAccountName: {{ include "__NAME__.serviceAccountName" . }}
      {{- with .Values.priorityClassName }}
      priorityClassName: {{ . }}
      {{- end }}
      securityContext:
        {{- if .Values.openShift.enabled }}
        {{- omit .Values.podSecurityContext "runAsUser" "runAsGroup" "fsGroup" | toYaml | nindent 8 }}
        {{- else }}
        {{- toYaml .Values.podSecurityContext | nindent 8 }}
        {{- end }}
      {{- with .Values.initContainers }}
      initContainers:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      containers:
        - name: {{ .Chart.Name }}
          securityContext:
            {{- toYaml .Values.securityContext | nindent 12 }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          {{- with .Values.extraArgs }}
          args:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          ports:
            - name: {{ .Values.service.portName }}
              containerPort: {{ .Values.service.port }}
              protocol: TCP
          livenessProbe:
            tcpSocket:
              port: {{ .Values.service.portName }}
            initialDelaySeconds: 15
            periodSeconds: 20
          readinessProbe:
            tcpSocket:
              port: {{ .Values.service.portName }}
            initialDelaySeconds: 5
            periodSeconds: 10
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
          {{- with .Values.extraEnv }}
          env:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with .Values.extraEnvFrom }}
          envFrom:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- if or .Values.persistence .Values.configuration .Values.existingConfigMap .Values.extraVolumeMounts }}
          volumeMounts:
            {{- if .Values.persistence }}
            - name: data
              mountPath: {{ .Values.persistence.mountPath }}
            {{- end }}
            {{- if or .Values.configuration .Values.existingConfigMap }}
            - name: config
              mountPath: {{ .Values.configMountPath }}
              {{- with .Values.configSubPath }}
              subPath: {{ . }}
              {{- end }}
            {{- end }}
            {{- with .Values.extraVolumeMounts }}
            {{- toYaml . | nindent 12 }}
            {{- end }}
          {{- end }}
        {{- with .Values.sidecars }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
TPL

if [ "$WORKLOAD" = "deployment" ]; then
  cat > "${CHART_DIR}/templates/deployment.yaml" <<TPL
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "__NAME__.fullname" . }}
  labels:
    {{- include "__NAME__.labels" . | nindent 4 }}
spec:
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "__NAME__.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      {{- if or .Values.configuration .Values.podAnnotations }}
      annotations:
        {{- if .Values.configuration }}
        checksum/config: {{ .Values.configuration | sha256sum }}
        {{- end }}
        {{- with .Values.podAnnotations }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
      {{- end }}
      labels:
        {{- include "__NAME__.labels" . | nindent 8 }}
        {{- with .Values.podLabels }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
    spec:
${POD_SPEC}
      {{- with .Values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- if or .Values.configuration .Values.existingConfigMap .Values.extraVolumes }}
      volumes:
        {{- if or .Values.configuration .Values.existingConfigMap }}
        - name: config
          configMap:
            name: {{ if .Values.existingConfigMap }}{{ .Values.existingConfigMap }}{{ else }}{{ include "__NAME__.fullname" . }}-config{{ end }}
        {{- end }}
        {{- with .Values.extraVolumes }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
      {{- end }}
TPL
else
  cat > "${CHART_DIR}/templates/statefulset.yaml" <<TPL
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: {{ include "__NAME__.fullname" . }}
  labels:
    {{- include "__NAME__.labels" . | nindent 4 }}
spec:
  serviceName: {{ include "__NAME__.fullname" . }}-headless
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "__NAME__.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      {{- if or .Values.configuration .Values.podAnnotations }}
      annotations:
        {{- if .Values.configuration }}
        checksum/config: {{ .Values.configuration | sha256sum }}
        {{- end }}
        {{- with .Values.podAnnotations }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
      {{- end }}
      labels:
        {{- include "__NAME__.labels" . | nindent 8 }}
        {{- with .Values.podLabels }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
    spec:
${POD_SPEC}
      {{- with .Values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- if or (not .Values.persistence.enabled) .Values.configuration .Values.existingConfigMap .Values.extraVolumes }}
      volumes:
        {{- if not .Values.persistence.enabled }}
        - name: data
          emptyDir: {}
        {{- end }}
        {{- if or .Values.configuration .Values.existingConfigMap }}
        - name: config
          configMap:
            name: {{ if .Values.existingConfigMap }}{{ .Values.existingConfigMap }}{{ else }}{{ include "__NAME__.fullname" . }}-config{{ end }}
        {{- end }}
        {{- with .Values.extraVolumes }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
      {{- end }}
  {{- if .Values.persistence.enabled }}
  volumeClaimTemplates:
    - metadata:
        name: data
      spec:
        accessModes:
          {{- toYaml .Values.persistence.accessModes | nindent 10 }}
        {{- if .Values.persistence.storageClass }}
        storageClassName: {{ .Values.persistence.storageClass }}
        {{- end }}
        resources:
          requests:
            storage: {{ .Values.persistence.size }}
  {{- end }}
TPL

  cat > "${CHART_DIR}/templates/service-headless.yaml" <<'TPL'
apiVersion: v1
kind: Service
metadata:
  name: {{ include "__NAME__.fullname" . }}-headless
  labels:
    {{- include "__NAME__.labels" . | nindent 4 }}
spec:
  clusterIP: None
  ports:
    - port: {{ .Values.service.port }}
      targetPort: {{ .Values.service.portName }}
      protocol: TCP
      name: {{ .Values.service.portName }}
  selector:
    {{- include "__NAME__.selectorLabels" . | nindent 4 }}
TPL
fi

cat > "${CHART_DIR}/templates/service.yaml" <<'TPL'
apiVersion: v1
kind: Service
metadata:
  name: {{ include "__NAME__.fullname" . }}
  labels:
    {{- include "__NAME__.labels" . | nindent 4 }}
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: {{ .Values.service.portName }}
      protocol: TCP
      name: {{ .Values.service.portName }}
  selector:
    {{- include "__NAME__.selectorLabels" . | nindent 4 }}
TPL

cat > "${CHART_DIR}/templates/serviceaccount.yaml" <<'TPL'
{{- if .Values.serviceAccount.create -}}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ include "__NAME__.serviceAccountName" . }}
  labels:
    {{- include "__NAME__.labels" . | nindent 4 }}
  {{- with .Values.serviceAccount.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
automountServiceAccountToken: {{ .Values.serviceAccount.automount }}
{{- end }}
TPL

cat > "${CHART_DIR}/templates/configmap.yaml" <<'TPL'
{{- if .Values.config -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "__NAME__.fullname" . }}
  labels:
    {{- include "__NAME__.labels" . | nindent 4 }}
data:
  {{- toYaml .Values.config | nindent 2 }}
{{- end }}
TPL

cat > "${CHART_DIR}/templates/config.yaml" <<'TPL'
{{- if and .Values.configuration (not .Values.existingConfigMap) }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "__NAME__.fullname" . }}-config
  labels:
    {{- include "__NAME__.labels" . | nindent 4 }}
data:
  {{ .Values.configFileName }}: |
    {{- .Values.configuration | nindent 4 }}
{{- end }}
TPL

cat > "${CHART_DIR}/templates/ingress.yaml" <<'TPL'
{{- if .Values.ingress.enabled -}}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ include "__NAME__.fullname" . }}
  labels:
    {{- include "__NAME__.labels" . | nindent 4 }}
  {{- with .Values.ingress.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- if .Values.ingress.className }}
  ingressClassName: {{ .Values.ingress.className }}
  {{- end }}
  {{- with .Values.ingress.tls }}
  tls:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  rules:
    {{- range .Values.ingress.hosts }}
    - host: {{ .host | quote }}
      http:
        paths:
          {{- range .paths }}
          - path: {{ .path }}
            pathType: {{ .pathType }}
            backend:
              service:
                name: {{ include "__NAME__.fullname" $ }}
                port:
                  number: {{ $.Values.service.port }}
          {{- end }}
    {{- end }}
{{- end }}
TPL

cat > "${CHART_DIR}/templates/hpa.yaml" <<'TPL'
{{- if .Values.autoscaling.enabled -}}
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {{ include "__NAME__.fullname" . }}
  labels:
    {{- include "__NAME__.labels" . | nindent 4 }}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: {{ if .Values.persistence }}StatefulSet{{ else }}Deployment{{ end }}
    name: {{ include "__NAME__.fullname" . }}
  minReplicas: {{ .Values.autoscaling.minReplicas }}
  maxReplicas: {{ .Values.autoscaling.maxReplicas }}
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: {{ .Values.autoscaling.targetCPUUtilizationPercentage }}
{{- end }}
TPL

cat > "${CHART_DIR}/templates/pdb.yaml" <<'TPL'
{{- if .Values.podDisruptionBudget.enabled -}}
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: {{ include "__NAME__.fullname" . }}
  labels:
    {{- include "__NAME__.labels" . | nindent 4 }}
spec:
  {{- with .Values.podDisruptionBudget.minAvailable }}
  minAvailable: {{ . }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "__NAME__.selectorLabels" . | nindent 6 }}
{{- end }}
TPL

cat > "${CHART_DIR}/templates/networkpolicy.yaml" <<'TPL'
{{- if .Values.networkPolicy.enabled -}}
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: {{ include "__NAME__.fullname" . }}
  labels:
    {{- include "__NAME__.labels" . | nindent 4 }}
spec:
  podSelector:
    matchLabels:
      {{- include "__NAME__.selectorLabels" . | nindent 6 }}
  policyTypes:
    - Ingress
  ingress:
    {{- toYaml .Values.networkPolicy.ingress | nindent 4 }}
{{- end }}
TPL

cat > "${CHART_DIR}/templates/servicemonitor.yaml" <<'TPL'
{{- if .Values.metrics.serviceMonitor.enabled -}}
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: {{ include "__NAME__.fullname" . }}
  labels:
    {{- include "__NAME__.labels" . | nindent 4 }}
    {{- with .Values.metrics.serviceMonitor.labels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
spec:
  selector:
    matchLabels:
      {{- include "__NAME__.selectorLabels" . | nindent 6 }}
  endpoints:
    - port: {{ .Values.service.portName }}
      interval: {{ .Values.metrics.serviceMonitor.interval }}
      scrapeTimeout: {{ .Values.metrics.serviceMonitor.scrapeTimeout }}
{{- end }}
TPL

cat > "${CHART_DIR}/templates/route.yaml" <<'TPL'
{{- if .Values.route.enabled -}}
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: {{ include "__NAME__.fullname" . }}
  labels:
    {{- include "__NAME__.labels" . | nindent 4 }}
  {{- with .Values.route.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- with .Values.route.host }}
  host: {{ . }}
  {{- end }}
  to:
    kind: Service
    name: {{ include "__NAME__.fullname" . }}
    weight: 100
  {{- with .Values.route.port }}
  port:
    targetPort: {{ . }}
  {{- end }}
  {{- with .Values.route.tls }}
  tls:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  wildcardPolicy: {{ .Values.route.wildcardPolicy }}
{{- end }}
TPL

cat > "${CHART_DIR}/templates/NOTES.txt" <<'TPL'
{{ .Chart.Name }} has been installed.

Release name: {{ .Release.Name }}
Namespace:    {{ .Release.Namespace }}

Reach the service from inside the cluster at:

  {{ include "__NAME__.fullname" . }}.{{ .Release.Namespace }}.svc.cluster.local:{{ .Values.service.port }}

To port forward to your workstation:

  kubectl --namespace {{ .Release.Namespace }} port-forward svc/{{ include "__NAME__.fullname" . }} {{ .Values.service.port }}:{{ .Values.service.port }}

Run the bundled connection test with:

  helm test {{ .Release.Name }} --namespace {{ .Release.Namespace }}
TPL

cat > "${CHART_DIR}/templates/tests/test-connection.yaml" <<'TPL'
apiVersion: v1
kind: Pod
metadata:
  name: "{{ include "__NAME__.fullname" . }}-test-connection"
  labels:
    {{- include "__NAME__.labels" . | nindent 4 }}
  annotations:
    "helm.sh/hook": test
    "helm.sh/hook-delete-policy": before-hook-creation,hook-succeeded
spec:
  restartPolicy: Never
  securityContext:
    runAsNonRoot: true
    {{- if not .Values.openShift.enabled }}
    runAsUser: 65534
    {{- end }}
    seccompProfile:
      type: RuntimeDefault
  containers:
    - name: test-connection
      image: {{ .Values.tests.image }}
      securityContext:
        allowPrivilegeEscalation: false
        readOnlyRootFilesystem: true
        capabilities:
          drop:
            - ALL
      command: ["sh", "-c"]
      args:
        - nc -z -w5 {{ include "__NAME__.fullname" . }} {{ .Values.service.port }}
      resources:
        requests:
          cpu: 10m
          memory: 16Mi
        limits:
          cpu: 50m
          memory: 32Mi
TPL

cat > "${CHART_DIR}/README.md" <<'MD'
# __NAME__

A Helm chart for __NAME__.

## Install

### HTTP repository

```sh
helm repo add kymelio https://kymeliodev.github.io/kymelio-helm
helm repo update
helm install my-__NAME__ kymelio/__NAME__
```

### OCI registry

```sh
helm install my-__NAME__ oci://ghcr.io/kymeliodev/kymelio-helm/__NAME__ --version 0.1.0
```

## Uninstall

```sh
helm uninstall my-__NAME__
```

## Upgrading

Review the chart version change and your overridden values before upgrading:

```sh
helm upgrade my-__NAME__ kymelio/__NAME__ --reuse-values
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas when autoscaling is disabled |
| image.repository | string | `""` | Container image repository |
| image.pullPolicy | string | `IfNotPresent` | Image pull policy |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| service.type | string | `ClusterIP` | Kubernetes Service type |
| service.port | int | `8080` | Service port |
| ingress.enabled | bool | `false` | Enable an Ingress resource |
| autoscaling.enabled | bool | `false` | Enable a HorizontalPodAutoscaler |
| podDisruptionBudget.enabled | bool | `false` | Enable a PodDisruptionBudget |
| networkPolicy.enabled | bool | `false` | Enable a NetworkPolicy |
| metrics.serviceMonitor.enabled | bool | `false` | Create a Prometheus ServiceMonitor |
| resources | object | requests and limits | Container resource requests and limits |
| podSecurityContext | object | runAsNonRoot | Pod security context |
| securityContext | object | drop ALL | Container security context |
MD

cat > "${CHART_DIR}/.helmignore" <<'IGN'
.git/
.gitignore
.DS_Store
*.swp
*.bak
*.orig
*~
ci/
IGN

# Replace the chart name placeholder across all generated files.
find "${CHART_DIR}" -type f -exec sed -i "s/__NAME__/${NAME}/g" {} +

echo "Created chart at charts/${NAME}"
