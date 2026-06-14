{{/*
Expand the name of the chart.
*/}}
{{- define "mysql.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "mysql.fullname" -}}
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
{{- define "mysql.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "mysql.labels" -}}
helm.sh/chart: {{ include "mysql.chart" . }}
{{ include "mysql.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: {{ include "mysql.name" . }}
{{- end }}

{{/*
Selector labels.
*/}}
{{- define "mysql.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mysql.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Service account name.
*/}}
{{- define "mysql.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "mysql.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Name of the Secret holding the credentials.
*/}}
{{- define "mysql.secretName" -}}
{{- if .Values.auth.existingSecret }}
{{- .Values.auth.existingSecret }}
{{- else }}
{{- include "mysql.fullname" . }}
{{- end }}
{{- end }}

{{/*
Resolve the root password. Reuse an existing value on upgrade so a generated
password stays stable across releases.
*/}}
{{- define "mysql.rootPassword" -}}
{{- if .Values.auth.rootPassword }}
{{- .Values.auth.rootPassword }}
{{- else }}
{{- $existing := lookup "v1" "Secret" .Release.Namespace (include "mysql.fullname" .) }}
{{- if and $existing (index $existing.data .Values.auth.secretKeys.rootPasswordKey) }}
{{- index $existing.data .Values.auth.secretKeys.rootPasswordKey | b64dec }}
{{- else }}
{{- randAlphaNum 24 }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Resolve the application user password. Reuse an existing value on upgrade so a
generated password stays stable across releases.
*/}}
{{- define "mysql.password" -}}
{{- if .Values.auth.password }}
{{- .Values.auth.password }}
{{- else }}
{{- $existing := lookup "v1" "Secret" .Release.Namespace (include "mysql.fullname" .) }}
{{- if and $existing (index $existing.data .Values.auth.secretKeys.passwordKey) }}
{{- index $existing.data .Values.auth.secretKeys.passwordKey | b64dec }}
{{- else }}
{{- randAlphaNum 24 }}
{{- end }}
{{- end }}
{{- end }}
