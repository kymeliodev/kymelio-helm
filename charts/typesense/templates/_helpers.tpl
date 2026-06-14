{{/*
Expand the name of the chart.
*/}}
{{- define "typesense.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "typesense.fullname" -}}
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
{{- define "typesense.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "typesense.labels" -}}
helm.sh/chart: {{ include "typesense.chart" . }}
{{ include "typesense.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: {{ include "typesense.name" . }}
{{- end }}

{{/*
Selector labels.
*/}}
{{- define "typesense.selectorLabels" -}}
app.kubernetes.io/name: {{ include "typesense.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Service account name.
*/}}
{{- define "typesense.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "typesense.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Name of the Secret holding the API key.
*/}}
{{- define "typesense.secretName" -}}
{{- if .Values.auth.existingSecret }}
{{- .Values.auth.existingSecret }}
{{- else }}
{{- include "typesense.fullname" . }}
{{- end }}
{{- end }}

{{/*
Resolve the API key. Reuse an existing value on upgrade so a generated key
stays stable across releases.
*/}}
{{- define "typesense.apiKey" -}}
{{- if .Values.auth.apiKey }}
{{- .Values.auth.apiKey }}
{{- else }}
{{- $existing := lookup "v1" "Secret" .Release.Namespace (include "typesense.fullname" .) }}
{{- if and $existing (index $existing.data .Values.auth.secretKeys.apiKeyKey) }}
{{- index $existing.data .Values.auth.secretKeys.apiKeyKey | b64dec }}
{{- else }}
{{- randAlphaNum 32 }}
{{- end }}
{{- end }}
{{- end }}
