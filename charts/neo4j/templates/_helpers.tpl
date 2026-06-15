{{/*
Expand the name of the chart.
*/}}
{{- define "neo4j.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "neo4j.fullname" -}}
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
{{- define "neo4j.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "neo4j.labels" -}}
helm.sh/chart: {{ include "neo4j.chart" . }}
{{ include "neo4j.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: {{ include "neo4j.name" . }}
{{- end }}

{{/*
Selector labels.
*/}}
{{- define "neo4j.selectorLabels" -}}
app.kubernetes.io/name: {{ include "neo4j.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Service account name.
*/}}
{{- define "neo4j.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "neo4j.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Name of the Secret holding the database credentials.
*/}}
{{- define "neo4j.secretName" -}}
{{- if .Values.auth.existingSecret }}
{{- .Values.auth.existingSecret }}
{{- else }}
{{- include "neo4j.fullname" . }}
{{- end }}
{{- end }}

{{/*
Resolve the password. Reuse an existing value on upgrade so a generated
password stays stable across releases. The Secret stores "neo4j/<password>",
so the stored value is split and the username prefix removed.
*/}}
{{- define "neo4j.password" -}}
{{- if .Values.auth.password }}
{{- .Values.auth.password }}
{{- else }}
{{- $existing := lookup "v1" "Secret" .Release.Namespace (include "neo4j.fullname" .) }}
{{- if and $existing (index $existing.data .Values.auth.secretKeys.authKey) }}
{{- index $existing.data .Values.auth.secretKeys.authKey | b64dec | trimPrefix (printf "%s/" .Values.auth.username) }}
{{- else }}
{{- randAlphaNum 24 }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Authentication string stored in the Secret, formatted as "username/password".
*/}}
{{- define "neo4j.authString" -}}
{{ .Values.auth.username }}/{{ include "neo4j.password" . }}
{{- end }}

{{/*
Convert a neo4j.conf setting name into the environment variable form expected by
the official image. Dots become single underscores and literal underscores are
doubled, then the NEO4J_ prefix is added.
*/}}
{{- define "neo4j.envName" -}}
{{- printf "NEO4J_%s" (. | replace "_" "__" | replace "." "_") -}}
{{- end }}
