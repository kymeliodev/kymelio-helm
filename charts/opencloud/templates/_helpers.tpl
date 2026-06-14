{{/*
Expand the name of the chart.
*/}}
{{- define "opencloud.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "opencloud.fullname" -}}
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
{{- define "opencloud.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "opencloud.labels" -}}
helm.sh/chart: {{ include "opencloud.chart" . }}
{{ include "opencloud.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: {{ include "opencloud.name" . }}
{{- end }}

{{/*
Selector labels.
*/}}
{{- define "opencloud.selectorLabels" -}}
app.kubernetes.io/name: {{ include "opencloud.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Service account name.
*/}}
{{- define "opencloud.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "opencloud.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Name of the Secret holding the admin credentials.
*/}}
{{- define "opencloud.secretName" -}}
{{- if .Values.auth.existingSecret }}
{{- .Values.auth.existingSecret }}
{{- else }}
{{- include "opencloud.fullname" . }}
{{- end }}
{{- end }}

{{/*
Resolve the admin password. Reuse an existing value on upgrade so a
generated password stays stable across releases.
*/}}
{{- define "opencloud.password" -}}
{{- if .Values.auth.adminPassword }}
{{- .Values.auth.adminPassword }}
{{- else }}
{{- $existing := lookup "v1" "Secret" .Release.Namespace (include "opencloud.fullname" .) }}
{{- if and $existing (index $existing.data .Values.auth.secretKeys.passwordKey) }}
{{- index $existing.data .Values.auth.secretKeys.passwordKey | b64dec }}
{{- else }}
{{- randAlphaNum 24 }}
{{- end }}
{{- end }}
{{- end }}
