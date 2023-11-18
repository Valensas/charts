{{/*
Expand the name of the chart.
*/}}
{{- define "speaky.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "speaky.fullname" -}}
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
{{- define "speaky.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "speaky.labels" -}}
helm.sh/chart: {{ include "speaky.chart" . }}
{{ include "speaky.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "speaky.selectorLabels" -}}
app.kubernetes.io/name: {{ include "speaky.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "speaky.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "speaky.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "speaky.podLabels" -}}
{{- include "speaky.labels" . | nindent 8 }}
{{- with .Values.podLabels }}
{{- toYaml . | nindent 8 }}
{{- end }}
checksum/config: {{ include (print $.Template.BasePath "/config/configmap.yaml") . | sha256sum }}
{{- end }}

{{- define "speaky.podAnnotations" -}}
{{- with .Values.podAnnotations }}
{{- toYaml . | nindent 8 }}
{{- end }}
checksum/config: {{ include (print $.Template.BasePath "/config/configmap.yaml") . | sha256sum }}
{{- if .Values.firebase.enabled }}
checksum/firebase-secret: {{ include (print $.Template.BasePath "/config/firebase-secret.yaml") . | sha256sum }}
{{- end }}
{{- if and .Values.sms.enabled (eq .Values.sms.method "phone") }}
checksum/sms-secret: {{ include (print $.Template.BasePath "/config/sms-secret.yaml") . | sha256sum }}
{{- end }}
{{- if .Values.email.enabled }}
checksum/smtp-secret: {{ include (print $.Template.BasePath "/config/smtp-secret.yaml") . | sha256sum }}
checksum/smtp-config: {{ include (print $.Template.BasePath "/config/smtp-config.yaml") . | sha256sum }}
{{- end }}
{{- end }}