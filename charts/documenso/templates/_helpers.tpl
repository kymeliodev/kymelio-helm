{{/*
Expand the name of the chart.
*/}}
{{- define "documenso.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "documenso.fullname" -}}
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
{{- define "documenso.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "documenso.labels" -}}
helm.sh/chart: {{ include "documenso.chart" . }}
{{ include "documenso.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: {{ include "documenso.name" . }}
{{- end }}

{{/*
Selector labels.
*/}}
{{- define "documenso.selectorLabels" -}}
app.kubernetes.io/name: {{ include "documenso.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Service account name.
*/}}
{{- define "documenso.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "documenso.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Name of the Secret holding the application secrets.
*/}}
{{- define "documenso.secretName" -}}
{{- if .Values.auth.existingSecret }}
{{- .Values.auth.existingSecret }}
{{- else }}
{{- include "documenso.fullname" . }}
{{- end }}
{{- end }}

{{/*
Resolve a generated secret value. Reuse the value stored in an existing release
Secret so generated material stays stable across upgrades.
Call with a dict (dict "ctx" . "key" "<secretKey>" "len" <int>).
*/}}
{{- define "documenso.generatedSecret" -}}
{{- $ctx := .ctx -}}
{{- $existing := lookup "v1" "Secret" $ctx.Release.Namespace (include "documenso.fullname" $ctx) -}}
{{- if and $existing (index $existing.data .key) -}}
{{- index $existing.data .key | b64dec -}}
{{- else -}}
{{- randAlphaNum .len -}}
{{- end -}}
{{- end }}
