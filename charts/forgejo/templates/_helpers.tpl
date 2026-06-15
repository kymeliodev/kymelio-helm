{{/*
Expand the name of the chart.
*/}}
{{- define "forgejo.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "forgejo.fullname" -}}
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
{{- define "forgejo.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "forgejo.labels" -}}
helm.sh/chart: {{ include "forgejo.chart" . }}
{{ include "forgejo.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: {{ include "forgejo.name" . }}
{{- end }}

{{/*
Selector labels.
*/}}
{{- define "forgejo.selectorLabels" -}}
app.kubernetes.io/name: {{ include "forgejo.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Service account name.
*/}}
{{- define "forgejo.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "forgejo.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Name of the Secret holding the admin credentials.
*/}}
{{- define "forgejo.secretName" -}}
{{- if .Values.admin.existingSecret }}
{{- .Values.admin.existingSecret }}
{{- else }}
{{- include "forgejo.fullname" . }}
{{- end }}
{{- end }}

{{/*
Resolve the admin password. Reuse an existing value on upgrade so a
generated password stays stable across releases.
*/}}
{{- define "forgejo.password" -}}
{{- if .Values.admin.password }}
{{- .Values.admin.password }}
{{- else }}
{{- $existing := lookup "v1" "Secret" .Release.Namespace (include "forgejo.fullname" .) }}
{{- if and $existing (index $existing.data .Values.admin.secretKeys.passwordKey) }}
{{- index $existing.data .Values.admin.secretKeys.passwordKey | b64dec }}
{{- else }}
{{- randAlphaNum 24 }}
{{- end }}
{{- end }}
{{- end }}
