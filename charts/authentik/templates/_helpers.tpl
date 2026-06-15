{{/*
Expand the name of the chart.
*/}}
{{- define "authentik.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "authentik.fullname" -}}
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
{{- define "authentik.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "authentik.labels" -}}
helm.sh/chart: {{ include "authentik.chart" . }}
{{ include "authentik.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: {{ include "authentik.name" . }}
{{- end }}

{{/*
Selector labels.
*/}}
{{- define "authentik.selectorLabels" -}}
app.kubernetes.io/name: {{ include "authentik.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Service account name.
*/}}
{{- define "authentik.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "authentik.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Name of the Secret holding the authentik secret key.
*/}}
{{- define "authentik.secretName" -}}
{{- if .Values.auth.existingSecret }}
{{- .Values.auth.existingSecret }}
{{- else }}
{{- include "authentik.fullname" . }}
{{- end }}
{{- end }}

{{/*
Resolve the authentik secret key. Reuse an existing value on upgrade so a
generated key stays stable across releases.
*/}}
{{- define "authentik.secretKey" -}}
{{- if .Values.auth.secretKey }}
{{- .Values.auth.secretKey }}
{{- else }}
{{- $existing := lookup "v1" "Secret" .Release.Namespace (include "authentik.fullname" .) }}
{{- if and $existing (index $existing.data .Values.auth.secretKeys.secretKeyKey) }}
{{- index $existing.data .Values.auth.secretKeys.secretKeyKey | b64dec }}
{{- else }}
{{- randAlphaNum 50 }}
{{- end }}
{{- end }}
{{- end }}
