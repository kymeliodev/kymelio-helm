{{/*
Expand the name of the chart.
*/}}
{{- define "vault.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "vault.fullname" -}}
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
{{- define "vault.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "vault.labels" -}}
helm.sh/chart: {{ include "vault.chart" . }}
{{ include "vault.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: {{ include "vault.name" . }}
{{- end }}

{{/*
Selector labels.
*/}}
{{- define "vault.selectorLabels" -}}
app.kubernetes.io/name: {{ include "vault.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Service account name.
*/}}
{{- define "vault.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "vault.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Name of the Secret holding the development root token.
*/}}
{{- define "vault.secretName" -}}
{{- if .Values.auth.existingSecret }}
{{- .Values.auth.existingSecret }}
{{- else }}
{{- include "vault.fullname" . }}
{{- end }}
{{- end }}

{{/*
Resolve the development root token. Reuse an existing value on upgrade so a
generated token stays stable across releases.
*/}}
{{- define "vault.rootToken" -}}
{{- if .Values.auth.rootToken }}
{{- .Values.auth.rootToken }}
{{- else }}
{{- $existing := lookup "v1" "Secret" .Release.Namespace (include "vault.fullname" .) }}
{{- if and $existing (index $existing.data .Values.auth.secretKeys.rootTokenKey) }}
{{- index $existing.data .Values.auth.secretKeys.rootTokenKey | b64dec }}
{{- else }}
{{- randAlphaNum 24 }}
{{- end }}
{{- end }}
{{- end }}
