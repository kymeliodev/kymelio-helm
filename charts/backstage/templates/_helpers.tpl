{{/*
Expand the name of the chart.
*/}}
{{- define "backstage.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "backstage.fullname" -}}
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
{{- define "backstage.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "backstage.labels" -}}
helm.sh/chart: {{ include "backstage.chart" . }}
{{ include "backstage.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: {{ include "backstage.name" . }}
{{- end }}

{{/*
Selector labels.
*/}}
{{- define "backstage.selectorLabels" -}}
app.kubernetes.io/name: {{ include "backstage.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Service account name.
*/}}
{{- define "backstage.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "backstage.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Name of the Secret holding the database password and backend secret.
*/}}
{{- define "backstage.secretName" -}}
{{- if .Values.existingSecret }}
{{- .Values.existingSecret }}
{{- else }}
{{- include "backstage.fullname" . }}
{{- end }}
{{- end }}

{{/*
Resolve the PostgreSQL password. Reuse an existing value on upgrade so a
generated password stays stable across releases.
*/}}
{{- define "backstage.postgresPassword" -}}
{{- if .Values.postgresql.password }}
{{- .Values.postgresql.password }}
{{- else }}
{{- $existing := lookup "v1" "Secret" .Release.Namespace (include "backstage.fullname" .) }}
{{- if and $existing (index $existing.data .Values.secretKeys.postgresPasswordKey) }}
{{- index $existing.data .Values.secretKeys.postgresPasswordKey | b64dec }}
{{- else }}
{{- randAlphaNum 24 }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Resolve the backend signing secret. Reuse an existing value on upgrade.
*/}}
{{- define "backstage.backendSecret" -}}
{{- if .Values.backend.secret }}
{{- .Values.backend.secret }}
{{- else }}
{{- $existing := lookup "v1" "Secret" .Release.Namespace (include "backstage.fullname" .) }}
{{- if and $existing (index $existing.data .Values.secretKeys.backendSecretKey) }}
{{- index $existing.data .Values.secretKeys.backendSecretKey | b64dec }}
{{- else }}
{{- randAlphaNum 32 }}
{{- end }}
{{- end }}
{{- end }}
