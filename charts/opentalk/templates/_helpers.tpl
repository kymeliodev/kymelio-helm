{{/*
Expand the name of the chart.
*/}}
{{- define "opentalk.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "opentalk.fullname" -}}
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
{{- define "opentalk.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "opentalk.labels" -}}
helm.sh/chart: {{ include "opentalk.chart" . }}
{{ include "opentalk.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: {{ include "opentalk.name" . }}
{{- end }}

{{/*
Selector labels.
*/}}
{{- define "opentalk.selectorLabels" -}}
app.kubernetes.io/name: {{ include "opentalk.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Service account name.
*/}}
{{- define "opentalk.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "opentalk.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Name of the Secret holding the service authentication key.
*/}}
{{- define "opentalk.secretName" -}}
{{- if .Values.auth.existingSecret }}
{{- .Values.auth.existingSecret }}
{{- else }}
{{- include "opentalk.fullname" . }}
{{- end }}
{{- end }}

{{/*
Resolve the service authentication key. Reuse an existing value on upgrade so a
generated key stays stable across releases.
*/}}
{{- define "opentalk.serviceKey" -}}
{{- if .Values.auth.serviceKey }}
{{- .Values.auth.serviceKey }}
{{- else }}
{{- $existing := lookup "v1" "Secret" .Release.Namespace (include "opentalk.fullname" .) }}
{{- if and $existing (index $existing.data .Values.auth.secretKeys.serviceKey) }}
{{- index $existing.data .Values.auth.secretKeys.serviceKey | b64dec }}
{{- else }}
{{- randAlphaNum 48 }}
{{- end }}
{{- end }}
{{- end }}
