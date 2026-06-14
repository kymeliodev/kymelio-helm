{{/*
Expand the name of the chart.
*/}}
{{- define "spicedb.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "spicedb.fullname" -}}
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
{{- define "spicedb.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "spicedb.labels" -}}
helm.sh/chart: {{ include "spicedb.chart" . }}
{{ include "spicedb.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: {{ include "spicedb.name" . }}
{{- end }}

{{/*
Selector labels.
*/}}
{{- define "spicedb.selectorLabels" -}}
app.kubernetes.io/name: {{ include "spicedb.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Service account name.
*/}}
{{- define "spicedb.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "spicedb.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Name of the Secret holding the preshared key.
*/}}
{{- define "spicedb.secretName" -}}
{{- if .Values.auth.existingSecret }}
{{- .Values.auth.existingSecret }}
{{- else }}
{{- include "spicedb.fullname" . }}
{{- end }}
{{- end }}

{{/*
Resolve the gRPC preshared key. Reuse an existing value on upgrade so a
generated key stays stable across releases.
*/}}
{{- define "spicedb.presharedKey" -}}
{{- if .Values.auth.presharedKey }}
{{- .Values.auth.presharedKey }}
{{- else }}
{{- $existing := lookup "v1" "Secret" .Release.Namespace (include "spicedb.fullname" .) }}
{{- if and $existing (index $existing.data .Values.auth.secretKeys.presharedKeyKey) }}
{{- index $existing.data .Values.auth.secretKeys.presharedKeyKey | b64dec }}
{{- else }}
{{- randAlphaNum 32 }}
{{- end }}
{{- end }}
{{- end }}
