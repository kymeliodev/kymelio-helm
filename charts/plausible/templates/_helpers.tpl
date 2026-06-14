{{/*
Expand the name of the chart.
*/}}
{{- define "plausible.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "plausible.fullname" -}}
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
{{- define "plausible.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "plausible.labels" -}}
helm.sh/chart: {{ include "plausible.chart" . }}
{{ include "plausible.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: {{ include "plausible.name" . }}
{{- end }}

{{/*
Selector labels.
*/}}
{{- define "plausible.selectorLabels" -}}
app.kubernetes.io/name: {{ include "plausible.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Service account name.
*/}}
{{- define "plausible.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "plausible.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Name of the Secret holding the application secret.
*/}}
{{- define "plausible.secretName" -}}
{{- if .Values.auth.existingSecret }}
{{- .Values.auth.existingSecret }}
{{- else }}
{{- include "plausible.fullname" . }}
{{- end }}
{{- end }}

{{/*
Resolve SECRET_KEY_BASE. Reuse the value stored in an existing release Secret
so the generated value stays stable across upgrades. Plausible expects a key of
at least 64 characters.
*/}}
{{- define "plausible.secretKeyBase" -}}
{{- if .Values.auth.secretKeyBase }}
{{- .Values.auth.secretKeyBase }}
{{- else }}
{{- $existing := lookup "v1" "Secret" .Release.Namespace (include "plausible.fullname" .) }}
{{- if and $existing (index $existing.data .Values.auth.secretKeys.secretKeyBaseKey) }}
{{- index $existing.data .Values.auth.secretKeys.secretKeyBaseKey | b64dec }}
{{- else }}
{{- randAlphaNum 64 }}
{{- end }}
{{- end }}
{{- end }}
