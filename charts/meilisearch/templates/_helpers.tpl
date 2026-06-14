{{/*
Expand the name of the chart.
*/}}
{{- define "meilisearch.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "meilisearch.fullname" -}}
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
{{- define "meilisearch.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "meilisearch.labels" -}}
helm.sh/chart: {{ include "meilisearch.chart" . }}
{{ include "meilisearch.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: {{ include "meilisearch.name" . }}
{{- end }}

{{/*
Selector labels.
*/}}
{{- define "meilisearch.selectorLabels" -}}
app.kubernetes.io/name: {{ include "meilisearch.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Service account name.
*/}}
{{- define "meilisearch.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "meilisearch.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Name of the Secret holding the master key.
*/}}
{{- define "meilisearch.secretName" -}}
{{- if .Values.auth.existingSecret }}
{{- .Values.auth.existingSecret }}
{{- else }}
{{- include "meilisearch.fullname" . }}
{{- end }}
{{- end }}

{{/*
Resolve the master key. Reuse an existing value on upgrade so a generated key
stays stable across releases.
*/}}
{{- define "meilisearch.masterKey" -}}
{{- if .Values.auth.masterKey }}
{{- .Values.auth.masterKey }}
{{- else }}
{{- $existing := lookup "v1" "Secret" .Release.Namespace (include "meilisearch.fullname" .) }}
{{- if and $existing (index $existing.data .Values.auth.secretKeys.masterKeyKey) }}
{{- index $existing.data .Values.auth.secretKeys.masterKeyKey | b64dec }}
{{- else }}
{{- randAlphaNum 32 }}
{{- end }}
{{- end }}
{{- end }}
