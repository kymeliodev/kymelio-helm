{{/*
Expand the name of the chart.
*/}}
{{- define "vikunja.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "vikunja.fullname" -}}
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
{{- define "vikunja.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "vikunja.labels" -}}
helm.sh/chart: {{ include "vikunja.chart" . }}
{{ include "vikunja.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: {{ include "vikunja.name" . }}
{{- end }}

{{/*
Selector labels.
*/}}
{{- define "vikunja.selectorLabels" -}}
app.kubernetes.io/name: {{ include "vikunja.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Service account name.
*/}}
{{- define "vikunja.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "vikunja.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Name of the Secret holding the JWT signing secret.
*/}}
{{- define "vikunja.secretName" -}}
{{- if .Values.auth.existingSecret }}
{{- .Values.auth.existingSecret }}
{{- else }}
{{- include "vikunja.fullname" . }}
{{- end }}
{{- end }}

{{/*
Resolve the JWT secret. Reuse the value stored in an existing release Secret
so the generated secret stays stable across upgrades.
*/}}
{{- define "vikunja.jwtSecret" -}}
{{- if .Values.auth.jwtSecret }}
{{- .Values.auth.jwtSecret }}
{{- else }}
{{- $existing := lookup "v1" "Secret" .Release.Namespace (include "vikunja.fullname" .) }}
{{- if and $existing (index $existing.data .Values.auth.secretKeys.jwtSecretKey) }}
{{- index $existing.data .Values.auth.secretKeys.jwtSecretKey | b64dec }}
{{- else }}
{{- randAlphaNum 48 }}
{{- end }}
{{- end }}
{{- end }}
