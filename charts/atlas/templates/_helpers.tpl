{{/*
Expand the name of the chart.
*/}}
{{- define "atlas.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "atlas.fullname" -}}
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
Create chart name and version as used by the chart label.
*/}}
{{- define "atlas.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "atlas.labels" -}}
helm.sh/chart: {{ include "atlas.chart" . }}
{{ include "atlas.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "atlas.selectorLabels" -}}
app.kubernetes.io/name: {{ include "atlas.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "atlas.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "atlas.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "atlas.podLabels" -}}
{{- include "atlas.labels" . }}
{{- with .Values.podLabels }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{- define "atlas.podAnnotations" -}}
{{- with .Values.podAnnotations }}
{{- toYaml . | nindent 8 }}
{{- end }}
config/checksum: {{ include (print $.Template.BasePath "/atlas-secret.yaml") . | sha256sum }}
{{- end }}